中文 | [English](../en/maintenance.md)

# 维护

日常维护、升级与回滚。首选命令是 `nh`（flake 已指向本仓库，自行提权）。

## 常用命令

| 命令 | 作用 |
|------|------|
| `nrs`（= `nh os switch`） | 应用 `.nix` 改动，切换系统世代 |
| `nh os build` | 仅构建验证，不切换（改动后首选验证方式） |
| `nix flake update` | 升级全部 flake 输入 |
| `nix flake update <name>` | 只升级一个 flake 输入 |
| `nh os switch -u` | 升级输入并应用 |
| `niri msg action load-config-file` | 热重载 Niri 配置 |
| `niri validate` | 校验 Niri 配置 |
| `mmsg dispatch reload_config` | 在 Mango 会话内热重载仓库活链接配置 |
| `systemctl --user status mango-session.target` | 查看 Mango 会话 target 与组件状态 |
| `journalctl --user -b -u 'mango-*'` | 查看本次启动的 Mango 组件日志 |

## 免 rebuild

`dotfiles/` 是到仓库的活链接，改动无需 rebuild，重启或 reload 对应程序即可。

## 自动维护

| 项目 | 机制 |
|------|------|
| 旧世代清理 | nh clean 每日执行（保留最近 3 个 + 7 天内世代） |
| Flatpak | 每日自动更新（`onActivation=false`，不阻塞 rebuild） |
| AI 技能 | nixkits `skills/` 链接到 `~/.agents/skills/`，随 `nix flake update` 更新 |

## 回滚

Mango 会话异常时，退出后在 greeter 按 `F3` 选择 Niri；greeter 会把该选择写入 `sync.toml`，下次继续使用。系统级改动出问题则从 GRUB 启动菜单选择旧世代，新世代不影响旧世代可用。

## Mango 会话维护

| 项目 | 操作或预期 |
|------|------------|
| 核心配置 | 编辑 `dotfiles/mango/config.conf` 及其模块，再运行 `mmsg dispatch reload_config`；活链接无需 rebuild，`nix flake check` 会复制源文件并用 `mango -p` 验证 |
| Shell 与样式 | 两套会话共用 Noctalia 设置；声明式 idle 在 `dotfiles/noctalia/idle.toml`，其他运行时设置由 Noctalia GUI 管理 |
| 空闲策略 | Noctalia 在 10 分钟锁屏、15 分钟关闭显示器、30 分钟锁屏并挂起；输入恢复时原生点亮显示器 |
| 运行时验收 | `echo "$XDG_CURRENT_DESKTOP"` 应为 `mango`；`systemctl --user is-active mango-session.target mango-noctalia.service mango-fcitx5.service mango-udiskie.service mango-xsettingsd.service mango-portal-watcher.service mango-screenshot-sound.service mango-clip-persist.service mango-cliphist-text.service mango-cliphist-image.service mango-wallpaper-random.service mango-gopeed.service` 应成功 |
| 退出验收 | 退出后 `mango-session-guard` 会停止 target；在 Niri 中 `systemctl --user is-active mango-session.target` 应为 `inactive` |
| Portal | 截图/共享屏幕异常时检查 `systemctl --user status xdg-desktop-portal.service` 和用户日志；Mango 的 wlr/gtk 路由由上游 NixOS 模块提供 |

## 改动归档

| 改动类型 | 位置 |
|------|------|
| GUI/CLI 软件 | `modules/features/apps.nix` / `modules/features/desktop.nix` / `modules/features/{niri,mango}.nix` / `modules/features/shell.nix` |
| 系统级组件 | `modules/features/` 对应文件的 nixos 部分 |
| 应用配置目录 | 通用目录在 `modules/features/dotfiles.nix` 登记；Niri/Mango 专属文件分别由 `niri.nix`/`mango.nix` 活链接，合成器无关脚本放在 `dotfiles/noctalia/scripts/` |
| 机器相关参数 | 一律走 `hosts/<host>/host.nix`，不要硬编码 |

## 手动维护场景

| 场景 | 步骤 |
|------|------|
| 新增 feature 模块 | 在 `modules/features/` 加文件（文件名即 aspect 名，目录自动聚合）→ 把名字加入 `modules/flake/hosts.nix` 的 `hostFeatureNames` 或 `userFeatureNames`；仅常规系统需要的 host feature 再加入 `installExcludedFeatureNames` |
| 新增主机 | 复制 `hosts/aspire-a715/` 为 `hosts/<新名>/`，改 `host.nix` 机器参数并生成 `hardware-configuration.nix`；全新机器直接用 `init.sh` |
| 新增用户 | 在 `hosts/<host>/host.nix` 增加 `users.<name> = { email = ...; isAdmin = ...; sshAuthorizedKeys = [ ... ]; };`；非主用户会自动在 `~/Documents/nix-dotfiles` 获得当前系统配置的只读快照链接，只有主用户还需设置 `primaryUser = "<name>"` |
| 修改机器参数 | 编辑 `hosts/<host>/host.nix`；`cpu`/`gpu` 取值受 `den.schema.host` 枚举约束（amd/intel、nvidia/amd/intel），拼错属性名会在装配层报错 |
| 升级单个 flake 输入 | `nix flake update <name>`（如 noctalia 发新版） |
| 验证改动 | 新增 Nix 文件先 `git add -N <file>` → `nix fmt` → `nix flake check`（含 Niri、`mango -p`、Noctalia 集成、TOML 与 ShellCheck）→ `nh os build`，确认无误再 `nrs` |

改 feature 挂载或装配逻辑前建议先读 [架构](architecture.md)。

## 注意

| 事项 | 说明 |
|------|------|
| 格式化 | 统一用 `nix fmt`（treefmt：nixfmt/stylua/shfmt + deadnix/statix，配置在 `modules/flake/formatting.nix`）；本仓库不再使用 kitsfmt |
| 密钥 | 改动 `secrets/` 后需 `nh os switch` 才刷新 `/run/agenix/` 明文 |
