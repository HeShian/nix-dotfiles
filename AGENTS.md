# AGENTS.md

> 面向 AI 编码助手的项目说明。本仓库是一份**个人 NixOS 桌面配置（dotfiles）**，不是传统意义上的软件项目：没有编译产物、没有测试套件，"构建"即 `nixos-rebuild`，"部署"即切换系统世代。

## 项目概览

- 基于 **NixOS（nixos-unstable）+ Niri（Wayland 滚动平铺合成器）+ Noctalia v5（Quickshell 桌面 Shell）** 的个人笔记本配置（单系统，Niri 配置中含合盖锁屏挂起等笔记本逻辑）。
- 通过 **Nix Flakes** 管理全部依赖，`flake.lock` 锁定版本；通过 **Home Manager**（作为 NixOS 模块）管理用户环境；通过 **Disko** 声明式分区。
- 本仓库 Fork 自 [huzch/nix-dotfiles](https://github.com/huzch/nix-dotfiles)（git 远端 `origin`），作者自己的推送远端是 `codeberg`（`https://codeberg.org/claudia010/nix-dotfiles.git`，推送 token 由 agenix 管理，见"安全注意事项"）。桌面实现主要参考 [SHORiN-KiWATA/shorin-arch-setup](https://github.com/SHORiN-KiWATA/shorin-arch-setup)（noctalia-dotfiles）。

## 技术栈与运行时架构

- **语言/格式**：Nix（系统与 Home Manager 配置）、KDL（Niri 配置）、Lua（Neovim，lazy.nvim 管理插件）、JSONC（fastfetch）、POSIX sh（安装脚本与 niri 脚本）、YAML（Rime 输入法）。
- **Flake 输入**（见 `flake.nix`）：`nixpkgs`(nixos-unstable)、`home-manager`、`disko`、`noctalia` + `noctalia-greeter`（greetd 登录界面）、`zen-browser`、`kimi-code`、`nixkits`（Kihara777/NixKits：kitsfmt 与 AI 技能来源；`nixpkgs.follows = "nixpkgs"` 以避免重复下载 nixpkgs 源码，代价是 kitsfmt 无法命中上游 cachix、本地源码编译）、`agenix`、`nix-flatpak`（`?ref=latest` 跟随最新 stable tag，声明式 flatpak 管理）。
- **Flake 输出**：
  - `nixosConfigurations.<hostName>`：完整系统（含 Home Manager）。
  - `nixosConfigurations.<hostName>-install`：精简安装系统（不含 Home Manager，供首装使用，避免引用尚不存在的 dotfiles 路径）。
  - 当前 `hostName = "westwood"`、`userName = "claudia"`，定义在 `nixos/host.nix`。
- **运行机制**：`nixos/host.nix` 是唯一的机器参数源（userName、userEmail、hostName、disk、cpu、gpu），通过 `specialArgs` 注入所有 NixOS 模块和 Home Manager 模块；`nixos/modules/hardware.nix` 按 `cpu`/`gpu` 条件化微码与显卡驱动（nvidia 使用开源内核模块）。

## 目录结构

- `flake.nix` / `flake.lock`：系统入口与依赖锁定。
- `nixos/`：系统级配置
  - `host.nix`：机器参数（由 `init.sh` 交互生成/改写）。
  - `configuration.nix`：仅 imports（`hardware-configuration.nix` + `disko.nix` + `modules/`）与 `system.stateVersion`；具体配置全部按主题拆分到 `modules/`。
  - `modules/`：按主题拆分的系统模块，`default.nix` 聚合导入全部：
    - `secrets.nix`：agenix（`age.identityPaths` 指定主机 host key + 5 个 `age.secrets.*`，`owner = userName`）。
    - `boot.nix`：内核（linuxPackages_latest）+ GRUB（UEFI removable 安装到 ESP 回退路径、os-prober 探测其他系统、Reboot/Poweroff 自定义条目、静默启动参数、Crossgrub 主题（fetchzip 自 GitHub release，已预取进 store）；`efiInstallAsRemovable` 要求 `canTouchEfiVariables = false`）。
    - `hardware.nix`：微码、graphics、NVIDIA（按 `cpu`/`gpu` 条件化，nvidia 用开源内核模块）、蓝牙、OpenTabletDriver、`services.xserver.videoDrivers`、nvidia 环境变量。
    - `locale.nix`：中文 locale + fcitx5/Rime（rime-ice 词库）、时区（Asia/Shanghai）、字体。
    - `networking.nix`：NetworkManager + v2raya + nftables（Waydroid 后端）+ OpenSSH（host key 与 agenix 复用同一把）。
    - `nix.nix`：Nix 设置（国内镜像 substituters + noctalia/nixkits cachix）、allowUnfree、nix-ld（FHS 兼容）。
    - `desktop.nix`：`programs.niri`、greetd + noctalia-greeter、xdg-desktop-portal（gnome/gtk 后端，Secret 走 gnome-keyring）、`environment.sessionVariables`（注意：`XDG_DATA_DIRS` 追加了 gsettings-desktop-schemas 路径，Noctalia 的 gsettings 钩子依赖，改动后需重新登录生效）+ `systemPackages`、Thunar（`programs.thunar` + gvfs + tumbler + udisks2）、Pipewire + rtkit、gnome-keyring、power-profiles-daemon。
    - `flatpak.nix`：由 **nix-flatpak** 声明式管理——flathub 中科大（主）/上交大（备）镜像 remote（直接指向 ostree 仓库 URL）、声明式安装 flatseal/wps365/betterbird/bottles/妙笔（wonderpen）/百度网盘、`update.auto` 每日自动更新（realtime timer；`update.onActivation` 保持 false，避免大体积下载阻塞 rebuild）。另含全局 `overrides.global.Environment.TZ = <time.timeZone>`（legacy 格式，v0.7.0 与新版均兼容）：NixOS 的 `/etc/localtime` 解析进 /nix/store，flatpak 沙箱无法映射会回退 UTC，靠注入 TZ 修复（Betterbird 邮件时间显示 UTC 即此问题）。
    - `virtualisation.nix`：libvirtd+KVM+virt-manager+spiceUSBRedirection、Waydroid。
    - `users.nix`：用户、zsh、sudo。
  - `disko.nix`：GPT 分区（1G ESP + 16G swap（支持休眠）+ btrfs 根卷，子卷 `/root`、`/home`、`/nix`，zstd 压缩 + noatime）。
  - `hardware-configuration.nix`：安装时由 `nixos-generate-config` 生成（**已提交进 git 跟踪**——flake 只读取 git 跟踪的文件，取消跟踪会导致每次 rebuild 报 "not tracked by Git"，因此有意保持跟踪；内容仍由安装流程生成，**不要手工维护**）。
- `home/`：Home Manager 用户配置（`home.stateVersion = "25.05"`），`default.nix` 汇总并导入；另在 `default.nix` 中把 nixkits flake 的 `skills/` 目录逐个链接到 `~/.agents/skills/`（kimi-code 用户级技能目录，nix store 只读链接，`nix flake update` + rebuild 即更新技能）
  - `desktop.nix`：Wayland 桌面工具（grim/slurp/cliphist/mpv/satty/sunsetr/fuzzel 等）、`home.pointerCursor`（Bibata 光标）、foot 终端（配色 include Noctalia 生成的 `~/.config/foot/themes/noctalia`；该文件缺失时 foot 会报错退出，由 `home.activation.footThemeFallback` 从 `dotfiles/foot/themes/noctalia` 种子一份兜底配色）、`~/Templates`"创建文档"模板（Office 模板二进制存于 `dotfiles/Templates/`）、`~/.config/xfce4/helpers.rc`（TerminalEmulator=foot）。**不使用 HM 的 `gtk` 模块**（GTK/Qt 颜色由 Noctalia 模板接管，避免争夺 `~/.config/gtk-*/`）。
  - `shell.nix`：zsh（vi 键位、别名、`nrs` = `nh os switch` 快捷别名）、git、fzf、yazi、neovim、nh（nix 命令助手，**首选系统管理命令**，每日自动清理：保留最近 3 个世代 + 7 天内的世代）。
  - `app.nix`：日常应用（brave + zen-browser(twilight) + pywalfox-native、IM、VSCode、opencode、kimi-code、kitsfmt（来自 nixkits 的 Nix 格式化器）、uv/python3、wine（wineWow64Packages.stableFull）+ winetricks、protonplus/lutris/heroic、waydroid-helper 等；steam 与 KDE Connect 由系统模块 `nixos/modules/desktop.nix` 的 `programs.steam`/`programs.kdeconnect` 提供，不在此安装）。另含 `home.activation.steamCjkFonts`：把 Noto Sans CJK 以**真实文件**复制到 `~/.local/share/fonts`（内容一致时跳过，不重复写 32MB）——Steam 客户端 UI 跑在 pressure-vessel 容器里（看不到 Nix store，符号链接无效），容器 fontconfig 通过 xdg fonts 目录发现它，否则 Steam 中文全部显示方框。
- `dotfiles/`：应用配置文件，由 `home/default.nix` 通过 `config.lib.file.mkOutOfStoreSymlink` 链接到 `~/.config/`（**指向仓库本身的活链接，不在 Nix store 中**）。
  - `niri/`：Niri 配置，按主题拆分为多个 `.kdl` 文件（`config.kdl` 为主入口，include `layout/animations/binds/windowrules/cursor/outputs/blur.kdl`）+ `scripts/`。**niri 是逐文件链接**（`~/.config/niri` 为真实目录）：`noctalia.kdl`（焦点环/边框等颜色）由 Noctalia 主题模板在运行时生成，不在仓库中；`config.kdl` 末尾已 include 它。`binds.kdl` 的键位布局复刻自 [shorin-arch-setup](https://github.com/SHORiN-KiWATA/shorin-arch-setup)（已适配 v5 `noctalia msg`、kitty→foot、firefox→brave）；`scripts/` 含 `portal-watcher.sh`（深浅色同步）、`screenshot-sound.sh`（截图快门声）、`screenshot-edit.sh`（satty 截图标注）、`niri-binds`（快捷键速查表）、`niri-force-kill-window`（强杀窗口）、`niri-pick`（窗口信息/取色）、`random-anime-wallpaper`（在线壁纸下载）。链接清单由 `home/default.nix` 用 `builtins.readDir` 自动枚举（顶层常规文件 + `scripts/` 下常规文件），新增脚本或 .kdl 文件无需手工登记。
  - `nvim/`：Neovim 配置（`init.lua` + `lua/core` + `lua/plugins`，lazy.nvim，锁定文件 `lazy-lock.json`）。配色由 `lua/noctalia.lua` 从 Noctalia 生成的 `~/.local/share/nvim/noctalia/colors.lua` 加载（SIGUSR1 热重载），文件缺失时回退内置 Catppuccin Mocha。`lua/matugen.lua` 是早期静态配色方案，已无任何文件引用，属遗留。
  - `fastfetch/`、`xsettingsd/`（图标主题为 `Adwaita-Matugen-B`，见下）、`rime/`（仅 `default.custom.yaml`，链接到 `~/.local/share/fcitx5/rime/`）、`Thunar/`（右键自定义动作 `uca.xml` + `accels.scm` 快捷键，配合 `~/Templates` 模板与 helpers.rc 的 foot）、`Templates/`（WPS 空白 Office 模板，经 `home/desktop.nix` 链到 `~/Templates/`）。
  - `noctalia/`：Noctalia 自定义主题模板源 + 初始配置种子。**不链接**到 `~/.config/noctalia`（Noctalia 的运行时状态不纳入 git 活链接），而是由 `home/default.nix` 的 `home.activation.noctaliaSeed` 在目标缺失时种子（详见该目录自带的 `README.md`）：
    - `config.toml` → `~/.config/noctalia/config.toml`（`[theme.templates.user.*]` 登记，`@REPO@` 占位符种子时替换）。
    - `settings.toml` → `~/.local/state/noctalia/settings.toml`（v5 全部设置：bar/小组件/主题/壁纸，`@HOME@` 占位符）。
    - `state/`：社区调色板/模板缓存，随 settings 一并种子，保证重装后主题离线可用。
    - `templates/neovim.lua`：nvim base16 配色模板。
    - `templates/gtk-folder/`：Adwaita 图标按当前调色板重着色到 `~/.local/share/icons/Adwaita-Matugen-{A,B}` 并通过 gsettings 翻转（A/B 交替强制应用刷新；xsettingsd 静态指向 B，GTK3 应用可能滞后一代换色）。
    - `templates/pywalfox-colors.json`：Pywalfox 配色模板（配合 `home/app.nix` 的 pywalfox-native，让 zen 浏览器主题跟随调色板）。
    - `templates/fcitx5-theme.conf`：fcitx5 候选框主题模板，生成 `~/.local/share/fcitx5/themes/noctalia/theme.conf`（深浅色/壁纸取色均跟随调色板）。热重载必须用 `post_hook` 里的 `fcitx5 -r`（无缝替换实例）——`fcitx5-remote -r` 只重读配置、不重读主题文件；fcitx5 侧 `classicui.conf` 需 `Theme=noctalia` + `UseAccentColor=False`，该文件由 fcitx5 运行时维护不入库。
- `init.sh`：Live ISO 下的两阶段安装脚本（见下文）。
- `secrets/`：agenix 密钥（`secrets.nix` 登记解密公钥 + `.age` 密文文件），用法见"安全注意事项"。
- `opencode.json`：opencode 的 MCP 配置（`uvx mcp-nixos`）。
- `README.md` / `README_EN.md`：面向人的安装与维护文档（含安装期代理配置说明）。

## 构建与修改命令

日常维护（在已安装的系统上，仓库位于 `~/Documents/nix-dotfiles`）：

```bash
# 应用 .nix 改动（软件包、服务、Nix 管理的文件）；nh 是首选系统管理命令
#（programs.nh.flake 已指向本仓库，nh 自行提权，无需 sudo）
nh os switch                        # 或 shell 别名 nrs；底层等价于 sudo nixos-rebuild switch --flake .#westwood

# 升级所有 flake 输入
nix flake update                    # 或 nh os switch -u（升级并应用）

# 仅评估/检查配置，不切换（验证改动的首选方式）
nh os build                         # 或 nix flake check --no-build / nixos-rebuild dry-build --flake .#westwood
```

- **只改 `dotfiles/` 下已有文件无需 rebuild**：它们是 out-of-store 软链接，重启或 reload 对应程序即可（Niri 用 `niri msg action load-config-file` 热重载）。
- 回滚：从 GRUB 启动菜单选择旧世代。

全新安装（Live ISO，**会格式化磁盘**）：

```bash
sudo -i
git clone <仓库地址> && cd nix-dotfiles
./init.sh            # 交互确认 host.nix 参数；输入 "ERASE <disk>" 才会分区
./init.sh --reset    # 清除断点状态，从头重来
```

`init.sh` 流程：交互改写 `nixos/host.nix` → disko 分区 → 生成 hardware-configuration → `nixos-install --flake .#<host>-install` → 拷贝仓库到 `/mnt/home/<user>/Documents/nix-dotfiles` 并克隆壁纸仓库（`~/Pictures/wallpapers`）→ chroot（nixos-enter）内 `nixos-rebuild switch` 完整配置 → 设密码。脚本用 `/mnt/var/lib/nix-dotfiles-install-state/` 记录步骤完成状态，支持断点重试。

**init.sh 重装后仍需手工处理的事项**（仓库外的运行时状态，脚本不覆盖）：

1. **agenix**：新机器 host key 不同 → 生成 `/etc/ssh/ssh_host_ed25519_key`（或从备份恢复），把新公钥加进 `secrets/secrets.nix` 并 `agenix -r` 重加密；用户的 `~/.ssh/id_ed25519` 从备份恢复后可正常查看/编辑密文。
2. **Noctalia 运行时配置**：已由 `home.activation.noctaliaSeed` 自动种子（`dotfiles/noctalia/` 下的 `config.toml`/`settings.toml`/`state/`），无需手工处理；只有想更新种子内容时才需按 `dotfiles/noctalia/README.md` 手动同步。
3. **Waydroid**：镜像不在仓库，需重新下载部署（网络问题见会话经验：v2rayA 代理 + OTA 时间戳绕过 init 下载）。
4. **flatpak 应用**：由 nix-flatpak 声明式管理，激活与每日 timer 自动补齐/更新，无需干预。
5. **gnome-keyring / 浏览器数据 / Noctalia 壁纸缓存**：不在仓库，随新系统重新生成。

## 代码风格约定

- **注释和文档主要使用中文**，新代码沿用这一惯例；标识符、文件路径保持英文。
- Nix 文件：两空格缩进，函数参数用 `{ config, lib, pkgs, ... }:` 解构；大量行内中文注释解释每个配置块的用途，保持这一密度。
- 机器相关的可变性（cpu/gpu/userName 等）一律通过 `nixos/host.nix` 的参数读取，**不要硬编码**。
- 新增 GUI/CLI 软件包：加到 `home/app.nix` 或 `home/shell.nix`/`home/desktop.nix`（按用途分类）；系统级组件加到 `nixos/modules/` 下对应主题文件（无对应主题时新建模块并在 `modules/default.nix` 登记）。
- 新增应用配置目录：放入 `dotfiles/<name>/`，并在 `home/default.nix` 的 `configs` 表中登记，使其链接到 `~/.config/<name>`。
- Niri 配置按主题拆分到对应 `.kdl` 文件，不要全部堆进 `config.kdl`。

## 测试与验证

本项目没有自动化测试。改动后的验证方式：

1. `nix flake check` 或 `nixos-rebuild dry-build --flake .#westwood` 确认求值无误。
2. `sudo nixos-rebuild switch` 应用；出问题从启动菜单回滚世代。
3. Niri 改动用 `niri msg action load-config-file` 热重载并检查 `niri validate`。
4. 修改 `init.sh` 后无法在本机完整测试（需要 Live ISO + 空磁盘），只做 `sh -n init.sh` 语法检查，逻辑改动需特别谨慎。
5. **kitsfmt 0.5.0 已知 bug**：会把 `++`（列表拼接）错误格式化成 `+`，破坏求值（2026-07 三次全仓库格式化分别踩中 4 处、3 处和 4 处，均已手工修复），两种模式下都会触发；其 best-practices 重写还会把 `with pkgs; [ ... ]` 改写成 `builtins.attrValues { inherit (pkgs) ...; }`（丢失列表内逐条注释、包顺序被字母排序）。本仓库**接受 attrValues 形式**（2026-07 第二次格式化起），包列表的逐条用途注释改写为列表上方的块注释（范例见 `home/desktop.nix` 的 `home.packages`）。每次运行 kitsfmt 后必须 `nixos-rebuild dry-build` 验证并检查 `++`→`+` 损坏。

## 安全注意事项

- **`init.sh` 会分区并格式化 `host.nix` 指定的整块磁盘**，任何对它的修改都必须保留 `ERASE <disk>` 确认与 `lsblk` 展示等防护逻辑。
- `init.sh` 顶部硬编码了代理环境变量（`http_proxy`/`https_proxy`），属作者个人网络环境，改动时注意这是安装期刚需而非可选项（README 有详细说明：Live ISO 阶段常用手机 USB 共享 + Clash Allow LAN）。
- `nixos/modules/` 中 `security.sudo.wheelNeedsPassword = false`（users.nix）、`nix.settings.sandbox = false`、`nixpkgs.config.allowUnfree = true`（nix.nix）均为有意的个人配置，不要"顺手修复"。
- `nixos/host.nix` 含个人邮箱；`hardware-configuration.nix` 只含 UUID 等机器信息、无密钥，有意保持 git 跟踪（见目录结构一节）。私密信息一律走 **agenix**：密文（`.age`）放 `secrets/` 提交进仓库，明文只存在于 `/run/agenix/`（tmpfs），不要提交任何明文密钥。
- agenix 工作方式：解密用主机 SSH host key（`/etc/ssh/ssh_host_ed25519_key`；`nixos/modules/secrets.nix` 通过 `age.identityPaths` 显式指定，OpenSSH 服务端已启用并复用同一把 host key）。`secrets/secrets.nix` 登记了两个解密公钥：`westwood`（主机 host key，系统激活时解密）与 `claudia`（用户 `~/.ssh/id_ed25519`，本机用 agenix CLI 查看/编辑密文）。现有密钥 `codeberg_token_nix_dotfiles` 用于 git 推送 codeberg 远端（本仓库的 `credential.helper` 在 `home/shell.nix` 的 git 配置中声明，运行时从 `/run/agenix/codeberg_token_nix_dotfiles` 读 token，不落盘）；`codeberg_token_secret` 用于 `~/Documents/Secret` 私有仓库推送（该仓库的 git `credential.helper` 运行时从 `/run/agenix/codeberg_token_secret` 读 token，不落盘）；`deepseek_api_copilot` 用于 VSCode Copilot 自定义端点；`deepseek_api_opencode` 用于 opencode；`github_token_codeberg` 为 GitHub PAT（ghp_ 前缀）。`age.secrets` 声明中 `owner = userName` 使用户可直接读取。
- 新增密钥：在 `secrets/secrets.nix` 登记公钥，然后在 `secrets/` 下 `echo -n "明文" | nix run github:ryantm/agenix -- -e <name>.age`，并在 `nixos/modules/secrets.nix` 声明 `age.secrets.<name>`。**重装系统 host key 会变，需用新公钥 `agenix -r` 重新加密全部密钥**。
- Home Manager 的 `backupFileExtension = "backup"`：已存在的冲突文件会被改名为 `.backup`，排查配置不生效问题时先检查这一点。
