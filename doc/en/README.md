[中文](../zh/README.md) | English

# NixOS Dotfiles Documentation

Personal NixOS desktop configuration: NixOS (nixos-unstable) + Niri + Noctalia v5.

## Overview

| Item | Value |
|------|-------|
| Host | westwood |
| User | claudia |
| Desktop | Niri (Wayland scrolling tiling) + Noctalia v5 (Quickshell) |
| Management | Nix Flakes (flake-parts + den) + Home Manager + Disko + agenix |
| Machine parameters | `hosts/<host>/host.nix` (userName/userEmail/disk/cpu/gpu/users) |

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
| `flake.nix` | System entry point and dependency lock (flake-parts + den + treefmt-nix) |
| `modules/flake/` | flake-parts wiring layer (auto-discovers `hosts/*`, den host/user assembly, `nix fmt` config) |
| `hosts/<host>/` | Per-machine config: `host.nix` parameters, `disko.nix` layout, `hardware-configuration.nix`; directory name is the host name |
| `modules/nixos/` | System-level modules (split by topic, auto-aggregated by the wiring layer) |
| `modules/home/` | Shared Home Manager config (every user gets it automatically) |
| `home/<user>/` | Thin per-user identity layer (imports the shared layer + git identity) |
| `overlays/` | Custom nixpkgs overlays (auto-aggregated) |
| `libs/` | Custom function library (aggregated as `mylib`, injected into all modules) |
| `dotfiles/` | App configs (live-linked to `~/.config`, no rebuild needed) |
| `secrets/` | agenix secrets (ciphertext in git, plaintext only in `/run/agenix/`) |
| `init.sh` | Two-stage Live ISO installer (formats the disk) |
| `doc/` | This documentation |

## Installation

See [README.md](../../README_EN.md) at the repo root for a fresh install (Live ISO + `init.sh`; partitioning requires typing `ERASE <disk>`).
