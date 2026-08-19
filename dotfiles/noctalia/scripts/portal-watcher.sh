#!/bin/sh
#
# portal-watcher.sh — 监听 portal color-scheme 变化，同步两套 Wayland 会话的 GTK3/GTK4 深浅色设置
# 由合成器会话常驻运行；依赖：dbus-send、flock、xsettingsd

RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
case ${WAYLAND_DISPLAY:-} in
/*) WAYLAND_SOCKET=$WAYLAND_DISPLAY ;;
"")
  echo "[portal-watcher] WAYLAND_DISPLAY is not set" >&2
  exit 1
  ;;
*) WAYLAND_SOCKET="${RUNTIME_DIR}/${WAYLAND_DISPLAY}" ;;
esac

# Niri 直接启动脚本、Mango 通过用户服务启动；切换会话时可能短暂重叠。
# 用户级锁让新实例等待旧 Wayland socket 消失，避免多个轮询器长期并存。
exec 9> "${RUNTIME_DIR}/noctalia-portal-watcher.lock"
flock 9

GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"

# 读取 portal color-scheme（1 = 深色）并应用
update_gtk() {
  scheme=$(dbus-send --session --print-reply \
    --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop \
    org.freedesktop.portal.Settings.Read \
    string:"org.freedesktop.appearance" string:"color-scheme" 2> /dev/null |
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

  pkill -HUP xsettingsd 2> /dev/null
}

prev=""
# 轮询而非事件监听：portal 没有可靠的 change 信号通路，1 秒轮询开销可忽略
while [ -S "$WAYLAND_SOCKET" ]; do
  scheme=$(dbus-send --session --print-reply \
    --dest=org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop \
    org.freedesktop.portal.Settings.Read \
    string:"org.freedesktop.appearance" string:"color-scheme" 2> /dev/null |
    grep uint32 | awk '{print $NF}')

  if [ "$scheme" != "$prev" ] && [ -n "$scheme" ]; then
    echo "[portal-watcher] color-scheme changed: $prev -> $scheme"
    update_gtk
    prev="$scheme"
  fi
  sleep 1
done
