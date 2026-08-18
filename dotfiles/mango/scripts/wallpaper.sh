#!/usr/bin/env bash
# 优先沿用用户现有壁纸；新机器没有该文件时仍能得到可预测的纯色背景。
set -euo pipefail

swaybg_cmd=${1:?swaybg command is required}
wallpaper="$HOME/Pictures/wallpapers/tropic_island_morning.jpg"

if [[ -f $wallpaper ]]; then
  exec "$swaybg_cmd" -m fill -i "$wallpaper"
fi

exec "$swaybg_cmd" -c '#201b14'
