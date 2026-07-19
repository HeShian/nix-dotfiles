# AGENTS.md

> 面向 AI 编码助手的项目说明。本仓库是一份**个人 NixOS 桌面配置（dotfiles）**，不是传统意义上的软件项目：没有编译产物、没有测试套件，"构建"即 `nixos-rebuild`，"部署"即切换系统世代。

## 项目概览

- 基于 **NixOS（nixos-unstable）+ Niri（Wayland 滚动平铺合成器）+ Noctalia v5（Quickshell 桌面 Shell）** 的个人台式机配置。
- 通过 **Nix Flakes** 管理全部依赖，`flake.lock` 锁定版本；通过 **Home Manager**（作为 NixOS 模块）管理用户环境；通过 **Disko** 声明式分区。
- 目标场景：台式机 + 独立 Linux 磁盘（Windows/Linux 双硬盘），单机单用户。
- 上游仓库：`https://github.com/huzch/nix-dotfiles`。

## 技术栈与运行时架构

- **语言/格式**：Nix（系统与 Home Manager 配置）、KDL（Niri 配置）、Lua（Neovim，lazy.nvim 管理插件）、JSONC（fastfetch）、POSIX sh（安装脚本）、YAML（Rime 输入法）。
- **Flake 输入**（见 `flake.nix`）：`nixpkgs`(nixos-unstable)、`home-manager`、`disko`、`noctalia` + `noctalia-greeter`（greetd 登录界面）、`zen-browser`、`kimi-code`、`agenix`。
- **Flake 输出**：
  - `nixosConfigurations.<hostName>`：完整系统（含 Home Manager）。
  - `nixosConfigurations.<hostName>-install`：精简安装系统（不含 Home Manager，供首装使用，避免引用尚不存在的 dotfiles 路径）。
  - 当前 `hostName = "westwood"`，定义在 `nixos/host.nix`。
- **运行机制**：`nixos/host.nix` 是唯一的机器参数源（userName、userEmail、hostName、disk、cpu、gpu），通过 `specialArgs` 注入所有 NixOS 模块和 Home Manager 模块；`configuration.nix` 按 `cpu`/`gpu` 条件化微码与显卡驱动（nvidia 使用开源内核模块）。

## 目录结构

- `flake.nix` / `flake.lock`：系统入口与依赖锁定。
- `nixos/`：系统级配置
  - `host.nix`：机器参数（由 `init.sh` 交互生成/改写）。
  - `configuration.nix`：引导、网络、时区（Asia/Shanghai）、中文 locale + fcitx5/Rime、字体、Pipewire、蓝牙、OpenTabletDriver、NVIDIA、greetd + noctalia-greeter、xdg-desktop-portal（gnome/gtk 后端）、Thunar（`programs.thunar` + gvfs + tumbler）、Flatpak（flathub 中科大/上交大镜像 + `flatpak-setup.service` 声明式安装 flatseal/wps365/betterbird）、虚拟化（libvirtd+KVM+virt-manager+spiceUSBRedirection）、Waydroid（nftables 后端）、用户、Nix 设置（国内镜像 substituters + noctalia cachix）。注意：`sessionVariables.XDG_DATA_DIRS` 追加了 gsettings-desktop-schemas 路径（Noctalia 的 gsettings 钩子依赖），改动后需重新登录生效。
  - `disko.nix`：GPT 分区（1G ESP + 16G swap + btrfs 根卷，子卷 `/root`、`/home`、`/nix`，zstd 压缩）。
  - `hardware-configuration.nix`：安装时由 `nixos-generate-config` 生成（在 `.gitignore` 中被忽略，**不要手工维护**）。
- `home/`：Home Manager 用户配置，`default.nix` 汇总并导入
  - `desktop.nix`：Wayland 桌面工具（grim/slurp/cliphist/mpv 等）、`home.pointerCursor`（Bibata 光标）、foot 终端。**不使用 HM 的 `gtk` 模块**（GTK/Qt 颜色由 Noctalia 模板接管，避免争夺 `~/.config/gtk-*/`）。
  - `shell.nix`：zsh（vi 键位、别名、`nrs` = nixos-rebuild 快捷别名）、git、fzf、yazi、nh（nix 命令助手，每日自动清理：保留最近 3 个世代 + 7 天内的世代）。
  - `app.nix`：日常应用（浏览器、IM、VSCode、opencode、kimi-code、steam、wine（wineWow64Packages.stableFull）+ winetricks、bottles/protonplus/lutris/heroic、waydroid-helper 等）。
- `dotfiles/`：应用配置文件，由 `home/default.nix` 通过 `config.lib.file.mkOutOfStoreSymlink` 链接到 `~/.config/`（**指向仓库本身的活链接，不在 Nix store 中**）。
  - `niri/`：Niri 配置，按主题拆分为多个 `.kdl` 文件（`config.kdl` 为主入口，另有 binds/layout/animations/windowrules 等）+ `scripts/`。**niri 是逐文件链接**（`~/.config/niri` 为真实目录）：`noctalia.kdl`（焦点环/边框等颜色）由 Noctalia 主题模板在运行时生成，不在仓库中；`config.kdl` 已 include 它。`binds.kdl` 的键位布局复刻自 [shorin-arch-setup](https://github.com/SHORiN-KiWATA/shorin-arch-setup)（已适配 v5 `noctalia msg` 与 foot）；`scripts/` 含 `portal-watcher.sh`（深浅色同步）、`screenshot-sound.sh`（截图快门声）、`niri-binds`（快捷键速查表）、`niri-force-kill-window`（强杀窗口）、`niri-pick`（窗口信息/取色）、`random-anime-wallpaper`（在线壁纸下载），新增脚本需在 `home/default.nix` 的 `niriFiles` 注册。
  - `nvim/`：Neovim 配置（`init.lua` + `lua/core` + `lua/plugins`，lazy.nvim，锁定文件 `lazy-lock.json`）。配色由 `lua/noctalia.lua` 从 Noctalia 生成的 `~/.local/share/nvim/noctalia/colors.lua` 加载（SIGUSR1 热重载），文件缺失时回退内置 Catppuccin Mocha。
  - `fastfetch/`、`xsettingsd/`（图标主题为 `Adwaita-Matugen-B`，见下）、`rime/`（链接到 `~/.local/share/fcitx5/rime/`）、`Thunar/`（右键自定义动作 uca.xml，配合 `~/Templates` 的"创建文档"模板与 `~/.config/xfce4/helpers.rc` 的 TerminalEmulator=foot）。
  - `noctalia/`：Noctalia 自定义主题模板源（`templates/neovim.lua`、`templates/gtk-folder/` 图标重着色）。**不链接**到 `~/.config/noctalia`（Noctalia 的运行时状态不纳入 git），模板在 `~/.config/noctalia/config.toml` 的 `[theme.templates.user.*]` 以绝对路径登记。`gtk-folder/recolor.sh` 把 Adwaita 图标按当前调色板重着色到 `~/.local/share/icons/Adwaita-Matugen-{A,B}` 并通过 gsettings 翻转（A/B 交替强制应用刷新；xsettingsd 静态指向 B，GTK3 应用可能滞后一代换色）。
  - 注意：`home/default.nix` 的 `configs` 表中含 `yazi`，新增对应的 `dotfiles/yazi/` 目录时才会生效。
- `init.sh`：Live ISO 下的两阶段安装脚本（见下文）。
- `secrets/`：agenix 密钥（`secrets.nix` 登记解密公钥 + `.age` 密文文件），用法见"安全注意事项"。
- `opencode.json`：opencode 的 MCP 配置（`uvx mcp-nixos`）。

## 构建与修改命令

日常维护（在已安装的系统上，仓库位于 `~/Documents/nix-dotfiles`）：

```bash
# 应用 .nix 改动（软件包、服务、Nix 管理的文件）
sudo nixos-rebuild switch --flake .#westwood   # 或 shell 别名 nrs

# 升级所有 flake 输入
nix flake update

# 仅评估/检查配置，不切换（验证改动的首选方式）
nix flake check --no-build        # 或 nixos-rebuild dry-build --flake .#westwood
```

- **只改 `dotfiles/` 下已有文件无需 rebuild**：它们是 out-of-store 软链接，重启或 reload 对应程序即可（Niri 用 `niri msg action load-config-file` 热重载）。
- 回滚：从 systemd-boot 启动菜单选择旧世代。

全新安装（Live ISO，**会格式化磁盘**）：

```bash
sudo -i
git clone https://github.com/huzch/nix-dotfiles.git && cd nix-dotfiles
./init.sh            # 交互确认 host.nix 参数；输入 "ERASE <disk>" 才会分区
./init.sh --reset    # 清除断点状态，从头重来
```

`init.sh` 流程：改写 `nixos/host.nix` → disko 分区 → 生成 hardware-configuration → `nixos-install --flake .#<host>-install` → 拷贝仓库到 `/mnt/home/<user>/Documents/nix-dotfiles` 并克隆壁纸仓库 → chroot 内 `nixos-rebuild switch` 完整配置 → 设密码。脚本用 `/mnt/var/lib/nix-dotfiles-install-state/` 记录步骤完成状态，支持断点重试。

## 代码风格约定

- **注释和文档主要使用中文**，新代码沿用这一惯例；标识符、文件路径保持英文。
- Nix 文件：两空格缩进，函数参数用 `{ config, lib, pkgs, ... }:` 解构；大量行内中文注释解释每个配置块的用途，保持这一密度。
- 机器相关的可变性（cpu/gpu/userName 等）一律通过 `nixos/host.nix` 的参数读取，**不要硬编码**。
- 新增 GUI/CLI 软件包：加到 `home/app.nix` 或 `home/shell.nix`/`home/desktop.nix`（按用途分类）；系统级组件加到 `nixos/configuration.nix`。
- 新增应用配置目录：放入 `dotfiles/<name>/`，并在 `home/default.nix` 的 `configs` 表中登记，使其链接到 `~/.config/<name>`。
- Niri 配置按主题拆分到对应 `.kdl` 文件，不要全部堆进 `config.kdl`。

## 测试与验证

本项目没有自动化测试。改动后的验证方式：

1. `nix flake check` 或 `nixos-rebuild dry-build --flake .#westwood` 确认求值无误。
2. `sudo nixos-rebuild switch` 应用；出问题从启动菜单回滚世代。
3. Niri 改动用 `niri msg action load-config-file` 热重载并检查 `niri validate`。
4. 修改 `init.sh` 后无法在本机完整测试（需要 Live ISO + 空磁盘），只做 `sh -n init.sh` 语法检查，逻辑改动需特别谨慎。

## 安全注意事项

- **`init.sh` 会分区并格式化 `host.nix` 指定的整块磁盘**，任何对它的修改都必须保留 `ERASE <disk>` 确认与 `lsblk` 展示等防护逻辑。
- `init.sh` 顶部硬编码了代理环境变量（`http_proxy`/`https_proxy`），属作者个人网络环境，改动时注意这是安装期刚需而非可选项。
- `configuration.nix` 中 `security.sudo.wheelNeedsPassword = false`、`nix.settings.sandbox = false`、`nixpkgs.config.allowUnfree = true` 均为有意的个人配置，不要"顺手修复"。
- `nixos/host.nix` 含个人邮箱；`hardware-configuration.nix` 已被 gitignore。私密信息一律走 **agenix**：密文（`.age`）放 `secrets/` 提交进仓库，明文只存在于 `/run/agenix/`（tmpfs），不要提交任何明文密钥。
- agenix 工作方式：解密用主机 SSH host key（`/etc/ssh/ssh_host_ed25519_key`，手工生成，未启用 sshd）；新增密钥时在 `secrets/secrets.nix` 登记公钥并在 `secrets/` 下 `echo -n "明文" | nix run github:ryantm/agenix -- -e <name>.age`，然后在 `configuration.nix` 声明 `age.secrets.<name>`。**重装系统 host key 会变，需用新公钥 `agenix -r` 重新加密全部密钥**。
- Home Manager 的 `backupFileExtension = "backup"`：已存在的冲突文件会被改名为 `.backup`，排查配置不生效问题时先检查这一点。
