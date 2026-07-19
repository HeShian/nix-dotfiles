#!/usr/bin/env bash
# 区域截图并用 satty 编辑（Mod+Shift+S）
# 说明：niri msg action screenshot 无论成功还是 ESC 取消都返回 0，
# 且剪贴板更新晚于命令返回，所以不能靠退出码/固定 sleep 判断，
# 改为对比剪贴板图片哈希：只有真正截到新图才打开 satty，取消则静默退出。

# 记录截图前的剪贴板图片哈希
before=$(wl-paste --type image 2>/dev/null | sha256sum | cut -d' ' -f1)

niri msg action screenshot --show-pointer false || exit 0

# 截图结束（无论成败），布防快门声
pkill -f -USR1 '[s]creenshot-sound.sh' 2>/dev/null || true

# 等待剪贴板出现“新”图片（最多 3 秒）
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
