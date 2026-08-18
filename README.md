中文 | [English](README_EN.md)

## 概览 (Overview)
![Desktop Screenshot](./doc/img/space.png)
![Fastfetch Screenshot](./doc/img/ff.png)

> 基于 NixOS 的双 Wayland 会话：Niri + Noctalia v5 为默认桌面，Mango + Waybar/SwayNC/Rofi 为独立备选桌面。

---

## 背景
我从 Ubuntu 入门，后来用 Arch，最后转到 NixOS。NixOS 的优势是声明式配置、版本锁定和世代回滚：系统可控，也容易恢复。

我现在只使用 NixOS 单系统，只有一台笔记本，没有台式机。

---

## ⚠️ 安装前需要知道的事
安装脚本会分区并格式化目标磁盘。NixOS 不能恢复被格式化的错误磁盘。运行前先用 `lsblk` 确认目标盘。

### 网络与代理配置 (Proxy Settings)
安装 NixOS、拉取 GitHub 仓库和 Nix 缓存可能需要代理。

- **Live ISO 环境**
  此时电脑上还没有代理软件。推荐用手机 USB 网络共享：手机连接电脑，打开"USB 网络共享"，并在 Clash 等代理工具中开启 "Allow LAN / 允许局域网连接"。

  然后在 Live ISO 里查手机共享出来的网关 IP：
  ```bash
  ip route
  ```

  找到类似 `default via 192.168.42.129 ...` 的地址，把它和代理端口写进 `init.sh`：
  ```bash
  export http_proxy="http://192.168.42.129:7890"
  export https_proxy="http://192.168.42.129:7890"
  ```

  也可以在运行时直接用环境变量覆盖（`init.sh` 里的值只是默认值）：
  ```bash
  sudo http_proxy="http://192.168.42.129:7890" https_proxy="http://192.168.42.129:7890" ./init.sh
  ```

- **安装后**
  重启进入新系统后，通常就可以使用电脑本机的代理客户端。此时系统代理应指向本机地址，而不是手机网关：
  ```nix
  # hosts/<host>/host.nix
  proxy = {
    default = "http://127.0.0.1:7890";
    noProxy = "127.0.0.1,::1,localhost";
  };
  ```

  如果你的代理端口不是 `7890`，按实际端口修改。

---

## 🚀 快速开始 (Quick Start)
> `dotfiles/` 通过 Home Manager 链接到 `~/.config/`。改应用配置通常不需要 rebuild，重启或 reload 对应程序即可。
>
> 安装脚本使用两阶段流程：先安装 `#<hostName>-install` 基础系统，再复制仓库并切换到完整 `#<hostName>` 配置。这样可以避免 Home Manager 在首装时引用还不存在的 dotfiles 路径。

### 在 U 盘系统 (Live ISO) 中安装
1. 将配置仓库克隆到本地：
```bash
sudo -i
git clone https://github.com/huzch/nix-dotfiles.git
cd nix-dotfiles
```
2. 执行安装脚本，按提示确认用户名、邮箱、主机名、磁盘、CPU/GPU、安装后代理和 SSH 公钥。脚本会显示 `lsblk`，并要求输入 `ERASE <disk>` 才会格式化：
```bash
./init.sh
```

脚本会询问以下配置，并写回 `hosts/<host>/host.nix`。方括号 `[]` 中是当前值，直接回车会沿用；圆括号 `()` 中是可选值。
```bash
User name [claudia]:
User email [3453289292@qq.com]:
Host name [aspire-a715]:
Target disk [/dev/nvme0n1]:
CPU (amd/intel) [intel]:
GPU (nvidia/amd/intel) [nvidia]:
Installed-system proxy [http://127.0.0.1:7890]:
SSH authorized key (optional) [ssh-ed25519 ...]:
```

| 优先级 | 配置项 | 需要确认的事 |
| --- | --- | --- |
| P0 | `DISK` | 确认不是 U 盘、移动硬盘或有重要数据的硬盘。 |
| P1 | `GPU` / `USER_NAME` / SSH 公钥 | GPU 影响桌面启动；用户名影响 home 目录；错误公钥会授予远程登录。 |
| P1 | 安装后代理 | 必须是新系统启动代理客户端后可用的地址，通常为 `127.0.0.1`。 |
| P2 | `CPU` / `HOST_NAME` | CPU 影响微码；主机名影响 flake 输出名。 |

安装完成后重启。脚本会准备 `~/Documents/nix-dotfiles` 和 `~/Pictures/wallpapers`。

脚本支持断点重试；断点会绑定主机、磁盘、用户和硬件参数，并校验 `/mnt` 所属磁盘。需要从头开始时，先核对并卸载 `/mnt`，再使用：
```bash
./init.sh --reset
```

### 💡 快捷键帮助
登录器默认进入 Niri，按 **`F3`** 可选择 Mango。Niri 日常使用按 **`Super + Shift + /`** 打开快捷键速查表；两套会话的键位与差异见 [快捷键文档](doc/zh/shortcuts.md)。

---

## 📁 目录结构说明 (Project Structure)
- **`flake.nix`**: 系统入口（flake-parts + den + treefmt-nix；装配逻辑在 `modules/flake/`）。
- **`modules/flake/`**: flake-parts 装配层。`hosts.nix` 自动发现 `hosts/*`，经 den 生成每台主机的 `<host>`/`<host>-install` 配置并挑选 feature aspects；`schema.nix` 元数据类型声明；`defaults.nix` 全局默认；`install-tools.nix` 导出锁定的 Disko app；`formatting.nix`/`checks.nix` 提供格式化和静态检查。装配细节见 [doc/zh/architecture.md](doc/zh/architecture.md)。
- **`hosts/aspire-a715/`**: 机器专属配置（每台机器一个 `hosts/<host>/` 目录，目录名即主机名）。
  - `host.nix`: 当前机器的磁盘、CPU/GPU、主用户、代理及逐用户权限/邮箱/SSH 公钥。
  - `default.nix`: 硬件/disko imports 与 `system.stateVersion`。
  - `hardware-configuration.nix`: 安装时生成的硬件配置。
  - `disko.nix`: 分区规则。
- **`modules/features/`**: feature aspects（一个文件一个 feature，文件名即 aspect 名；可同时含 nixos/homeManager 两类配置；目录自动聚合）。
- **`dotfiles/`**: Niri、Noctalia、Mango 配套组件、Neovim 等应用配置。

---

## 🛠️ 如何维护你的配置 (Maintenance)
### 1. 如何安装新软件？
- 系统组件：编辑 `modules/features/` 下对应文件的 nixos 部分。
- 日常软件：编辑 `modules/features/apps.nix`（或其他 feature 的 homeManager 部分）。

包名可在 [search.nixos.org](https://search.nixos.org/packages) 搜索。

### 2. 如何修改桌面外观或快捷键？
- Niri 合成器：编辑 `dotfiles/niri/config.kdl`，然后运行 `niri msg action load-config-file` 热重载。
- Noctalia Shell：通过 Noctalia 设置面板（`Super + F2`）或用 `Super + Z` 打开启动器后搜索设置。
- Mango 合成器：核心配置在 `modules/features/mango.nix`，修改后需 rebuild；Waybar/SwayNC/Rofi 等样式在 `dotfiles/mango/`，重启对应 `mango-*` 用户服务即可。

### 3. 如何新增 feature 模块、主机或用户？
装配结构（den aspect/includes、install 变体）见 [doc/zh/architecture.md](doc/zh/architecture.md)；具体步骤见 [doc/zh/maintenance.md](doc/zh/maintenance.md) 的「手动维护场景」。

### 4. 如何应用你的修改？
只修改 `dotfiles/` 下已有文件，通常不需要 rebuild。

修改 `.nix`、软件包、服务，或新增 Nix 管理的文件后执行：
```bash
cd ~/Documents/nix-dotfiles

git add .
nh os switch    # 首选系统管理命令（别名 nrs）；底层等价于 sudo nixos-rebuild switch --flake .#aspire-a715
```

升级锁定版本：
```bash
nh os switch -u    # 等价于 nix flake update + nh os switch
```

### 5. 如何格式化代码？
统一用 `nix fmt`（treefmt：nixfmt/stylua/shfmt + deadnix/statix；配置在 `modules/flake/formatting.nix`）。`nix flake check` 还会校验 Niri、上游 `mango -p`、Mango JSON 和一方 Shell 脚本。

---

## 🌟 为什么选择 NixOS？(Why NixOS?)
### 1. 绝对的稳定性：版本锁定
`flake.lock` 锁定依赖版本。不运行 `nix flake update`，包版本就不会主动变化。

### 2. 永不崩坏的系统："世代"与回滚
每次 `nixos-rebuild switch` 都会创建新世代。出问题时可从启动菜单回到旧世代。

### 3. "一次配置，到处运行"
系统、用户环境、桌面和应用配置都放在仓库里，方便重装、迁移和审计。

---

## 项目来源与参考

- Fork 自：[huzch/nix-dotfiles](https://github.com/huzch/nix-dotfiles)
- 主要参考：[SHORiN-KiWATA/shorin-arch-setup (noctalia-dotfiles)](https://github.com/SHORiN-KiWATA/shorin-arch-setup/tree/main/noctalia-dotfiles)
- Mango：[官方 Nix 选项](https://mangowm.github.io/docs/nix-options/)；视觉与组件思路参考 [DreamMaoMao/mango-config](https://github.com/DreamMaoMao/mango-config)
- 动画参考代码：https://lagrange-x.lanzouq.com/iQGv93sel3uf

---

## 反馈
Issue 和 PR 欢迎直接提。
