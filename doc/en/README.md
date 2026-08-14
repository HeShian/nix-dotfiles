[中文](../zh/README.md) | English

# NixOS Dotfiles Documentation

Personal NixOS desktop configuration: NixOS (nixos-unstable) + Niri + Noctalia v5.

## Overview

| Item | Value |
|------|-------|
| Host | westwood |
| User | claudia |
| Desktop | Niri (Wayland scrolling tiling) + Noctalia v5 (Quickshell) |
| Management | Nix Flakes + Home Manager + Disko + agenix |
| Machine parameters | `host.nix` (userName/hostName/disk/cpu/gpu) |

## Documents

| Document | Content |
|----------|---------|
| [Shortcuts](shortcuts.md) | All Niri keybindings |
| [Software](software.md) | Categorized software list |
| [Maintenance](maintenance.md) | Daily maintenance, upgrades, rollback |
| [agenix](agenix.md) | Secrets management |
| [Theming](theming.md) | Noctalia color pipeline |

## Layout

| Path | Content |
|------|---------|
| `flake.nix` | System entry point and dependency lock |
| `host.nix` | Machine parameters (single source for init.sh and the flake) |
| `hosts/westwood/` | Machine-specific config (disko layout, hardware-configuration) |
| `modules/nixos/` | System-level modules (split by topic) |
| `modules/home/` | Home Manager user config |
| `dotfiles/` | App configs (live-linked to `~/.config`, no rebuild needed) |
| `secrets/` | agenix secrets (ciphertext in git, plaintext only in `/run/agenix/`) |
| `init.sh` | Two-stage Live ISO installer (formats the disk) |
| `doc/` | This documentation |

## Installation

See [README.md](../../README_EN.md) at the repo root for a fresh install (Live ISO + `init.sh`; partitioning requires typing `ERASE <disk>`).
