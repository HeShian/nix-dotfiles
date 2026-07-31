中文 | [English](../en/theming.md)

# 主题

Noctalia 配色体系：壁纸 → 调色板 → 模板渲染到各应用，全局一键换色。

## 工作机制

| 环节 | 说明 |
|------|------|
| 取色 | Noctalia 从当前壁纸生成调色板（matugen） |
| 渲染 | 按 `dotfiles/noctalia/templates/` 的模板生成各应用配色 |
| 热重载 | 各应用通过 include/信号/钩子即时换色，无需重启 |

## 模板清单

| 目标 | 机制 |
|------|------|
| foot | 生成 `~/.config/foot/themes/noctalia`，主配置 include（缺失时种子兜底） |
| neovim | 生成 colors.lua，SIGUSR1 热重载（缺失时回退 Catppuccin Mocha） |
| GTK 图标 | Adwaita 按调色板重着色到 `Adwaita-Matugen-{A,B}`，A/B 交替强制刷新 |
| GTK/Qt 颜色 | Noctalia 模板接管（不用 HM gtk 模块） |
| zen 浏览器 | pywalfox 模板 + pywalfox-native |
| fcitx5 候选框 | 生成 noctalia 主题，`post_hook` 里 `fcitx5 -r` 无缝替换 |
| 深浅色 | `portal-watcher.sh` 通过 gsettings 同步 |

## 操作

| 操作 | 方式 |
|------|------|
| 换壁纸换色 | `Mod+F10` 随机切换，自动重新取色 |
| 下载在线壁纸 | `Mod+Shift+F10` |
| 手动选色/选壁纸 | `Mod+Alt+W` 壁纸面板、控制中心 |
| 深浅色切换 | 控制中心（跟随调色板自动联动上述全部） |

## 配置种子

`~/.config/noctalia` 不入 git（运行时状态），由 `home.activation.noctaliaSeed` 在目标**缺失时**从 `dotfiles/noctalia/` 种子（含社区调色板缓存，离线可用）。想更新种子内容，按 `dotfiles/noctalia/README.md` 手动同步回仓库。
