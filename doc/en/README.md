[中文](../zh/README.md) | English

# NixOS Dotfiles Documentation

Personal dual-desktop NixOS configuration: NixOS (nixos-unstable) + Niri/Noctalia v5 + Mango.

## Overview

| Item | Value |
|------|-------|
| Host | aspire-a715 |
| User | claudia |
| Desktop | Niri and Mango share Noctalia v5; the greeter remembers the last selection |
| Management | Nix Flakes (flake-parts + den) + Home Manager + Disko + agenix |
| Machine parameters | `hosts/<host>/host.nix` (disk/cpu/gpu/primaryUser/proxy/per-user metadata) |

## Documents

| Document | Content |
|----------|---------|
| [Architecture](architecture.md) | den wiring, aspect inventory, install variant |
| [Shortcuts](shortcuts.md) | Niri bindings, Mango counterparts, and differences |
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
| `modules/features/` | Feature aspects (one file per feature, file name = aspect name; may carry both classes; auto-aggregated) |
| `overlays/` | Custom nixpkgs overlays (auto-aggregated) |
| `libs/` | Custom function library (aggregated as `mylib`, injected into all modules) |
| `dotfiles/` | App configs (live-linked to `~/.config`, no rebuild needed) |
| `secrets/` | agenix secrets (ciphertext in git, plaintext only in `/run/agenix/`) |
| `init.sh` | Two-stage Live ISO installer (formats the disk) |
| `doc/` | This documentation |

## Installation

See [README.md](../../README_EN.md) at the repo root for a fresh install (Live ISO + `init.sh`; partitioning requires typing `ERASE <disk>`).
