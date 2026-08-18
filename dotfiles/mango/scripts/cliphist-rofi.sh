#!/usr/bin/env bash
# 从 cliphist 选择记录并写回 Wayland 剪贴板。
set -euo pipefail

cliphist_cmd=${1:?cliphist command is required}
rofi_cmd=${2:?rofi command is required}
wl_copy_cmd=${3:?wl-copy command is required}

selection=$(
  "$cliphist_cmd" list |
    "$rofi_cmd" -dmenu -i -config "$HOME/.config/mango/rofi/config.rasi" -p Clipboard
) || exit 0

if [[ -n $selection ]]; then
  printf '%s\n' "$selection" | "$cliphist_cmd" decode | "$wl_copy_cmd"
fi
