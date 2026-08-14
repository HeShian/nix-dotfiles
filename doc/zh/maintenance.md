中文 | [English](../en/maintenance.md)

# 维护

日常维护、升级与回滚。首选命令是 `nh`（flake 已指向本仓库，自行提权）。

## 常用命令

| 命令 | 作用 |
|------|------|
| `nrs`（= `nh os switch`） | 应用 `.nix` 改动，切换系统世代 |
| `nh os build` | 仅构建验证，不切换（改动后首选验证方式） |
| `nix flake update` | 升级全部 flake 输入 |
| `nh os switch -u` | 升级输入并应用 |
| `niri msg action load-config-file` | 热重载 Niri 配置 |
| `niri validate` | 校验 Niri 配置 |

## 免 rebuild

`dotfiles/` 是到仓库的活链接，改动无需 rebuild，重启或 reload 对应程序即可。

## 自动维护

| 项目 | 机制 |
|------|------|
| 旧世代清理 | nh clean 每日执行（保留最近 3 个 + 7 天内世代） |
| Flatpak | 每日自动更新（`onActivation=false`，不阻塞 rebuild） |
| AI 技能 | nixkits `skills/` 链接到 `~/.agents/skills/`，随 `nix flake update` 更新 |

## 回滚

从 GRUB 启动菜单选择旧世代。新世代出问题不影响旧世代可用。

## 改动归档

| 改动类型 | 位置 |
|------|------|
| GUI/CLI 软件 | `home/claudia/app.nix` / `home/claudia/desktop.nix` / `home/claudia/shell.nix` |
| 系统级组件 | `modules/nixos/` 对应主题文件 |
| 应用配置目录 | `dotfiles/<name>/`（在 `home/claudia/default.nix` 的 `configs` 登记） |
| 机器相关参数 | 一律走 `hosts/<host>/host.nix`，不要硬编码 |

## 注意

| 事项 | 说明 |
|------|------|
| kitsfmt `++` bug | 会把 `++` 格式化成 `+`，运行后必须 dry-build 验证并检查（见 AGENTS.md） |
| wemeet 块 | `overlays/wemeet.nix` 的 overrideAttrs 是手工格式（formatter bug），不要对它有格式洁癖 |
| 密钥 | 改动 `secrets/` 后需 `nh os switch` 才刷新 `/run/agenix/` 明文 |
