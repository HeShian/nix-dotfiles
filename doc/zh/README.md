中文 | [English](../en/README.md)

# NixOS Dotfiles 文档

个人 NixOS 桌面配置：NixOS（nixos-unstable）+ Niri + Noctalia v5。

## 基本信息

| 项目 | 值 |
|------|-----|
| 主机 | westwood |
| 用户 | claudia |
| 桌面 | Niri（Wayland 滚动平铺）+ Noctalia v5（Quickshell） |
| 管理 | Nix Flakes + Home Manager + Disko + agenix |
| 机器参数 | `hosts/<host>/host.nix`（userName/hostName/disk/cpu/gpu） |

## 文档索引

| 文档 | 内容 |
|------|------|
| [快捷键](shortcuts.md) | Niri 全部键位 |
| [软件](software.md) | 已安装软件分类清单 |
| [维护](maintenance.md) | 日常维护、升级与回滚 |
| [agenix](agenix.md) | 密钥管理 |
| [主题](theming.md) | Noctalia 配色体系 |

## 目录结构

| 路径 | 内容 |
|------|------|
| `flake.nix` | 系统入口与依赖锁定（自动发现 `hosts/*`） |
| `hosts/<host>/` | 每主机配置：`host.nix` 机器参数、`disko.nix` 分区、`hardware-configuration.nix` |
| `modules/nixos/` | 系统级模块（按主题拆分） |
| `modules/home/` | 共享 Home Manager 配置（所有用户自动获得） |
| `home/<user>/` | 每用户薄身份层（imports 共享层 + git 署名） |
| `overlays/` | 自定义 nixpkgs overlay（自动聚合） |
| `libs/` | 自定义函数库（聚合为 `mylib`，注入所有模块） |
| `dotfiles/` | 应用配置（活链接到 `~/.config`，改动无需 rebuild） |
| `secrets/` | agenix 密钥（密文入库，明文只在 `/run/agenix/`） |
| `init.sh` | Live ISO 两阶段安装脚本（会格式化磁盘） |
| `doc/` | 本文档目录 |

## 安装

全新安装见仓库根目录 [README.md](../../README.md)（Live ISO + `init.sh`，输入 `ERASE <disk>` 才会分区）。
