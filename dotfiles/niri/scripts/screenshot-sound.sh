#!/usr/bin/env bash
#
# screenshot-sound.sh — 截图快门声服务
#
# 触发方式：niri 启动时由 config.kdl 的 spawn-sh-at-startup 常驻运行；
#           截图快捷键（见 binds.kdl）截图结束后向本进程发 SIGUSR1「上膛」，
#           随后 wl-paste 监听到剪贴板出现新图片即播放快门声
# 依赖：pw-play（pipewire）、wl-paste（wl-clipboard）、notify-send

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
    # 只处理图片
    if wl-paste --list-types 2>/dev/null | grep -q 'image/'; then

        # 已上膛才继续（扳机文件存在）
        if [ -f \"$TRIGGER_FILE\" ]; then

            # 按扳机文件的修改时间判断上膛是否过期
            NOW=\$(date +%s)
            FILE_TIME=\$(stat -c %Y \"$TRIGGER_FILE\")
            DIFF=\$((NOW - FILE_TIME))

            if [ \$DIFF -lt $TIMEOUT_SEC ]; then
                # 条件齐备：是图片 + 已上膛 + 未过期
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

# 无限睡眠，只响应信号
while true; do
    sleep infinity & wait $!
done
