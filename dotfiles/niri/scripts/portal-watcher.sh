#!/bin/sh
#
# portal-watcher.sh — 监听 portal color-scheme 变化，同步 GTK3/GTK4 的深浅色设置
# 由 config.kdl spawn-sh-at-startup 常驻运行；依赖：dbus-send、xsettingsd

GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"

# 读取 portal color-scheme（1 = 深色）并应用
update_gtk() {
    scheme=$(dbus-send --session --print-reply \
        --dest=org.freedesktop.portal.Desktop \
        /org/freedesktop/portal/desktop \
        org.freedesktop.portal.Settings.Read \
        string:"org.freedesktop.appearance" string:"color-scheme" 2>/dev/null |
        grep uint32 | awk '{print $NF}')

    if [ "$scheme" = "1" ]; then
        pref="1"
    else
        pref="0"
    fi

    for ini in "$GTK3_INI" "$GTK4_INI"; do
        dir=$(dirname "$ini")
        [ -d "$dir" ] || mkdir -p "$dir"
        tmp="$ini.tmp"
        {
            # 键必须紧跟 [Settings] 段写入；追加到文件末尾可能落入其他段
            echo "[Settings]"
            echo "gtk-application-prefer-dark-theme=$pref"
            if [ -f "$ini" ]; then
                grep -v -e "gtk-application-prefer-dark-theme" -e "^\[Settings\]" "$ini"
            fi
        } > "$tmp" && mv "$tmp" "$ini"
    done

    pkill -HUP xsettingsd 2>/dev/null
}

prev=""
# 轮询而非事件监听：portal 没有可靠的 change 信号通路，1 秒轮询开销可忽略
while true; do
    scheme=$(dbus-send --session --print-reply \
        --dest=org.freedesktop.portal.Desktop \
        /org/freedesktop/portal/desktop \
        org.freedesktop.portal.Settings.Read \
        string:"org.freedesktop.appearance" string:"color-scheme" 2>/dev/null |
        grep uint32 | awk '{print $NF}')

    if [ "$scheme" != "$prev" ] && [ -n "$scheme" ]; then
        echo "[portal-watcher] color-scheme changed: $prev -> $scheme"
        update_gtk
        prev="$scheme"
    fi
    sleep 1
done
