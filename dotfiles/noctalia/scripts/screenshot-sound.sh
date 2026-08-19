#!/usr/bin/env bash
#
# screenshot-sound.sh — 双合成器截图快门声服务：快捷键发 SIGUSR1「上膛」，
# wl-paste 监听到剪贴板新图片即播放；由合成器会话常驻启动。依赖：flock、pw-play、wl-paste、notify-send

# ---------- 可调参数 ----------
SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/camera-shutter.oga"
# 用户运行时目录既是内存文件系统，也避免多用户共享同一个扳机文件。
RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
TRIGGER_FILE="${RUNTIME_DIR}/noctalia_screenshot_armed"
# 有效期：上膛后多少秒内剪贴板出现图片才响（避免取消截图后，下次复制图片误响）
TIMEOUT_SEC=15
# ------------------------------

case ${WAYLAND_DISPLAY:-} in
/*) WAYLAND_SOCKET=$WAYLAND_DISPLAY ;;
"")
  echo "错误: WAYLAND_DISPLAY 未设置" >&2
  exit 1
  ;;
*) WAYLAND_SOCKET="${RUNTIME_DIR}/${WAYLAND_DISPLAY}" ;;
esac

# 两套合成器的启动可能在切换时短暂重叠；等待旧实例随其 Wayland socket 退出后再接管。
exec 9> "${RUNTIME_DIR}/noctalia-screenshot-sound.lock"
flock 9

# 环境检查
if ! command -v pw-play > /dev/null; then
  notify-send "错误: 未找到 pw-play"
  exit 1
fi
if ! command -v wl-paste > /dev/null; then
  notify-send "错误: 未找到 wl-paste"
  exit 1
fi

# 信号处理：收到 SIGUSR1 即「上膛」（刷新扳机文件的修改时间，不存在则创建）
arm_trigger() {
  touch "$TRIGGER_FILE"
}

trap arm_trigger SIGUSR1

WATCHER_PID=""
cleanup() {
  if [[ -n $WATCHER_PID ]]; then
    kill "$WATCHER_PID" 2> /dev/null || true
    wait "$WATCHER_PID" 2> /dev/null || true
  fi
  rm -f "$TRIGGER_FILE"
}

trap cleanup EXIT
trap 'exit 0' INT TERM

# 写入当前 PID 方便调试（可选）
# echo $$ > /tmp/niri-sound.pid

echo "截图音效服务已启动，等待 SIGUSR1 信号..."

# wl-paste 绑定当前 Wayland socket；子进程意外退出时在同一会话内重启，
# socket 消失则结束整个脚本并释放单实例锁。SIGUSR1 只会中断 wait，不再创建永久 sleep。
export SOUND TIMEOUT_SEC TRIGGER_FILE
while [[ -S $WAYLAND_SOCKET ]]; do
  # 子进程先 cat 排空 stdin——wl-paste 会把整张图片写进管道，不读的话大图撑爆
  # 管道缓冲（64K）后 wl-paste 可能吃到 EPIPE，监听静默终止。
  wl-paste --watch bash -c '
    cat > /dev/null
    if wl-paste --list-types 2>/dev/null | grep -q "image/" && [[ -f $TRIGGER_FILE ]]; then
      now=$(date +%s)
      file_time=$(stat -c %Y "$TRIGGER_FILE")
      if ((now - file_time < TIMEOUT_SEC)); then
        pw-play "$SOUND" &
        rm -f "$TRIGGER_FILE"
      fi
    fi
  ' &
  WATCHER_PID=$!

  while kill -0 "$WATCHER_PID" 2> /dev/null; do
    wait "$WATCHER_PID" 2> /dev/null || true
  done
  wait "$WATCHER_PID" 2> /dev/null || true
  WATCHER_PID=""

  [[ -S $WAYLAND_SOCKET ]] && sleep 1
done
