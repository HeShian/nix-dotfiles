#!/usr/bin/env bash
#
# screenshot-sound.sh — 截图快门声服务：binds.kdl 截图快捷键结束后发 SIGUSR1「上膛」，
# wl-paste 监听到剪贴板新图片即播放；由 config.kdl 常驻启动。依赖：pw-play、wl-paste、notify-send

# ---------- 可调参数 ----------
SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/camera-shutter.oga"
# 「扳机」文件，存于内存文件系统（/dev/shm），读写开销极小
TRIGGER_FILE="/dev/shm/niri_screenshot_armed"
# 有效期：上膛后多少秒内剪贴板出现图片才响（避免取消截图后，下次复制图片误响）
TIMEOUT_SEC=15
# ------------------------------

# 环境检查
if ! command -v pw-play >/dev/null; then
    notify-send "错误: 未找到 pw-play"
    exit 1
fi

# 信号处理：收到 SIGUSR1 即「上膛」（刷新扳机文件的修改时间，不存在则创建）
arm_trigger() {
    touch "$TRIGGER_FILE"
}

trap arm_trigger SIGUSR1

# 后台监听剪贴板：wl-paste --watch 只在剪贴板内容变化时唤醒子进程
wl-paste --watch bash -c "
    if wl-paste --list-types 2>/dev/null | grep -q 'image/'; then

        if [ -f \"$TRIGGER_FILE\" ]; then

            # 按扳机文件的修改时间判断上膛是否过期
            NOW=\$(date +%s)
            FILE_TIME=\$(stat -c %Y \"$TRIGGER_FILE\")
            DIFF=\$((NOW - FILE_TIME))

            if [ \$DIFF -lt $TIMEOUT_SEC ]; then
                pw-play \"$SOUND\" &

                # 销毁扳机，防止连响
                rm -f \"$TRIGGER_FILE\"
            fi
        fi
    fi
" &
# 记录监听子进程 PID，脚本退出时一并清理
WATCHER_PID=$!

# 主循环：无限睡眠只响应信号，退出时杀掉监听子进程
trap "kill $WATCHER_PID; exit" INT TERM EXIT

# 写入当前 PID 方便调试（可选）
# echo $$ > /tmp/niri-sound.pid

echo "截图音效服务已启动，等待 SIGUSR1 信号..."

while true; do
    sleep infinity & wait $!
done
