#!/usr/bin/env bash
# 区域截图并用 satty 编辑（Mod+Shift+S）
# niri 截图无论成功/ESC 取消都返回 0 且剪贴板更新滞后，故对比剪贴板图片哈希判断是否真的截到新图

before=$(wl-paste --type image 2>/dev/null | sha256sum | cut -d' ' -f1)

niri msg action screenshot --show-pointer false || exit 0

# 给快门声服务「上膛」
pkill -f -USR1 '[s]creenshot-sound.sh' 2>/dev/null || true

# 等待剪贴板出现「新」图片（最多 3 秒）
for _ in $(seq 1 30); do
    sleep 0.1
    now=$(wl-paste --type image 2>/dev/null | sha256sum | cut -d' ' -f1)
    if [ -n "$now" ] && [ "$now" != "$before" ]; then
        wl-paste --type image | satty -f - &
        exit 0
    fi
done

# 超时：截图被取消，静默退出
exit 0
