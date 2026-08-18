#!/usr/bin/env bash
# Mango 截图入口：区域、全屏与 Satty 标注共用同一输出目录。
set -euo pipefail

grim_cmd=${1:?grim command is required}
slurp_cmd=${2:?slurp command is required}
satty_cmd=${3:?satty command is required}
mode=${4:?screenshot mode is required}

shot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$shot_dir"
shot="$shot_dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

case "$mode" in
region)
  geometry=$("$slurp_cmd" -b '#201b1488' -c '#d79921ff') || exit 0
  "$grim_cmd" -g "$geometry" "$shot"
  ;;
output)
  "$grim_cmd" "$shot"
  ;;
annotate)
  geometry=$("$slurp_cmd" -b '#201b1488' -c '#d79921ff') || exit 0
  "$grim_cmd" -g "$geometry" -t ppm - | "$satty_cmd" -f -
  ;;
*)
  printf 'unknown screenshot mode: %s\n' "$mode" >&2
  exit 2
  ;;
esac
