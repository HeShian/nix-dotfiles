#!/usr/bin/env bash
# Mango 截图补充：窗口和当前显示器依赖 mmsg 几何信息，标注模式用 slurp + grim + Satty。
set -euo pipefail

mode=${1:-}
shot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$shot_dir"
shot="$shot_dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

arm_sound() {
  pkill -f -USR1 '[s]creenshot-sound.sh' 2> /dev/null || true
}

copy_shot() {
  arm_sound
  wl-copy --type image/png < "$shot"
}

case "$mode" in
window)
  client=$(mmsg get focusing-client) || exit 1
  geometry=$(jq -er '
    select(.error == null)
    | select((.width // 0) > 0 and (.height // 0) > 0)
    | "\(.x),\(.y) \(.width)x\(.height)"
  ' <<< "$client") || exit 1
  grim -g "$geometry" "$shot"
  copy_shot
  ;;
monitor)
  geometry=$(mmsg get all-monitors | jq -er '
    .monitors[]
    | select(.active == true)
    | "\(.x),\(.y) \(.width)x\(.height)"
  ') || exit 1
  grim -g "$geometry" "$shot"
  copy_shot
  ;;
annotate)
  geometry=$(slurp) || exit 0
  [[ -n $geometry ]] || exit 0
  grim -g "$geometry" "$shot"
  copy_shot
  satty \
    --filename "$shot" \
    --output-filename "$shot" \
    --copy-command wl-copy \
    --save-after-copy \
    --actions-on-enter save-to-clipboard \
    --early-exit copy
  ;;
*)
  printf '用法: %s {window|monitor|annotate}\n' "${0##*/}" >&2
  exit 2
  ;;
esac
