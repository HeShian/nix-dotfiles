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
| GUI/CLI 软件 | `modules/features/apps.nix` / `modules/features/desktop.nix` / `modules/features/shell.nix`（homeManager 部分） |
| 系统级组件 | `modules/features/` 对应文件的 nixos 部分 |
| 应用配置目录 | `dotfiles/<name>/`（在 `modules/features/dotfiles.nix` 的 `configs` 登记） |
| 机器相关参数 | 一律走 `hosts/<host>/host.nix`，不要硬编码 |

## 手动维护场景

| 场景 | 步骤 |
|------|------|
| 新增 feature 模块 | 在 `modules/features/` 加文件（文件名即 aspect 名，目录自动聚合）→ 把名字加入 `modules/flake/hosts.nix` 的 `hostFeatureNames` 或 `userFeatureNames`；仅常规系统需要的 host feature 再加入 `installExcludedFeatureNames` |
| 新增主机 | 复制 `hosts/aspire-a715/` 为 `hosts/<新名>/`，改 `host.nix` 机器参数并生成 `hardware-configuration.nix`；全新机器直接用 `init.sh` |
| 新增用户 | 在 `hosts/<host>/host.nix` 增加 `users.<name> = { email = ...; isAdmin = ...; sshAuthorizedKeys = [ ... ]; };`；只有主用户还需设置 `primaryUser = "<name>"` |
| 修改机器参数 | 编辑 `hosts/<host>/host.nix`；`cpu`/`gpu` 取值受 `den.schema.host` 枚举约束（amd/intel、nvidia/amd/intel），拼错属性名会在装配层报错 |
| 升级单个 flake 输入 | `nix flake update <name>`（如 noctalia 发新版） |
| 验证改动 | 新增 Nix 文件先 `git add -N <file>` → `nix fmt` → `nix flake check`（含 ShellCheck）→ `nh os build`，确认无误再 `nrs` |

改 feature 挂载或装配逻辑前建议先读 [架构](architecture.md)。

## 注意

| 事项 | 说明 |
|------|------|
| 格式化 | 统一用 `nix fmt`（treefmt：nixfmt/stylua/shfmt + deadnix/statix，配置在 `modules/flake/formatting.nix`）；本仓库不再使用 kitsfmt |
| 密钥 | 改动 `secrets/` 后需 `nh os switch` 才刷新 `/run/agenix/` 明文 |
