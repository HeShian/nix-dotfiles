#!/bin/sh
# Watch portal color-scheme and update GTK settings accordingly
# Noctalia v5 updates the portal when theme changes; this script syncs GTK

GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"

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
            echo "[Settings]"
            if [ -f "$ini" ]; then
                grep -v -e "gtk-application-prefer-dark-theme" -e "^\[Settings\]" "$ini"
            fi
            echo "gtk-application-prefer-dark-theme=$pref"
        } > "$tmp" && mv "$tmp" "$ini"
    done

    pkill -HUP xsettingsd 2>/dev/null
}

prev=""
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
