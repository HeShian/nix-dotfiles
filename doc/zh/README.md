中文 | [English](../en/README.md)

# NixOS Dotfiles 文档

个人 NixOS 双桌面配置：NixOS（nixos-unstable）+ Niri/Noctalia v5 + Mango。

## 基本信息

| 项目 | 值 |
|------|-----|
| 主机 | aspire-a715 |
| 用户 | claudia |
| 桌面 | 默认 Niri + Noctalia v5；备选 Mango + Waybar/SwayNC/Rofi |
| 管理 | Nix Flakes（flake-parts + den）+ Home Manager + Disko + agenix |
| 机器参数 | `hosts/<host>/host.nix`（disk/cpu/gpu/primaryUser/proxy/users 元数据） |

## 文档索引

| 文档 | 内容 |
|------|------|
| [架构](architecture.md) | den 装配结构、aspect 清单、install 变体 |
| [快捷键](shortcuts.md) | Niri 键位、Mango 对应键位与差异 |
| [软件](software.md) | 已安装软件分类清单 |
| [维护](maintenance.md) | 日常维护、升级与回滚 |
| [agenix](agenix.md) | 密钥管理 |
| [主题](theming.md) | Noctalia 配色体系 |

## 目录结构

| 路径 | 内容 |
|------|------|
| `flake.nix` | 系统入口与依赖锁定（flake-parts + den + treefmt-nix） |
| `modules/flake/` | flake-parts 装配层（自动发现 `hosts/*`、den 主机/用户装配、`nix fmt` 配置） |
| `hosts/<host>/` | 每主机配置：`host.nix` 机器参数、`disko.nix` 分区、`hardware-configuration.nix`；目录名即主机名 |
| `modules/features/` | feature aspects（一个文件一个 feature，文件名即 aspect 名；可同时含两类配置；自动聚合） |
| `overlays/` | 自定义 nixpkgs overlay（自动聚合） |
| `libs/` | 自定义函数库（聚合为 `mylib`，注入所有模块） |
| `dotfiles/` | 应用配置（活链接到 `~/.config`，改动无需 rebuild） |
| `secrets/` | agenix 密钥（密文入库，明文只在 `/run/agenix/`） |
| `init.sh` | Live ISO 两阶段安装脚本（会格式化磁盘） |
| `doc/` | 本文档目录 |

## 安装

全新安装见仓库根目录 [README.md](../../README.md)（Live ISO + `init.sh`，输入 `ERASE <disk>` 才会分区）。
