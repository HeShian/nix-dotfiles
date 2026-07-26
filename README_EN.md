## Overview
![Desktop Screenshot](./space.png)
![Fastfetch Screenshot](./ff.png)

> Personal NixOS + Niri + Noctalia v5 desktop configuration. This README covers install checks and daily maintenance.

---

## Background
I started with Ubuntu, moved through Arch, and ended up on NixOS. NixOS gives me declarative config, locked versions, and rollback points.

I now run NixOS as the only OS on a single laptop — no desktop PC, no dual boot.

---

## ⚠️ Before You Install
The installer partitions and formats the target disk. NixOS cannot restore the wrong disk after formatting. Check the target with `lsblk` first.

### Network And Proxy Notes
Installing NixOS and fetching GitHub / Nix cache resources may require a proxy.

- **Stage 1: Live ISO environment**
  The machine does not have a proxy client yet. A practical option is USB tethering from a phone: connect the phone, enable USB tethering, and enable "Allow LAN" in Clash or your proxy app.

  In the Live ISO, find the phone gateway IP:
  ```bash
  ip route
  ```

  Look for an address like `default via 192.168.42.129 ...`, then set it and the proxy port in `init.sh`:
  ```bash
  export http_proxy="http://192.168.42.129:7890"
  export https_proxy="http://192.168.42.129:7890"
  ```

- **Stage 2: Installed NixOS system**
  After rebooting into the installed system, you can usually use a proxy client on the computer itself. Point the system proxy to localhost, not the phone gateway:
  ```nix
  networking.proxy.default = "http://127.0.0.1:7890";
  ```

  Change `7890` if your proxy client uses another port.

---

## Quick Start
> Home Manager links `dotfiles/` into `~/.config/`. Most app config changes only need an app reload, not a system rebuild.
>
> The installer uses two stages: install the base `#<hostName>-install` system, then copy the repository and switch to the full `#<hostName>` configuration. This avoids Home Manager referencing dotfile paths before they exist.

### Install From A Live ISO
1. Clone this repository:
```bash
sudo -i
git clone https://github.com/huzch/nix-dotfiles.git
cd nix-dotfiles
```

2. Run the installer and confirm username, email, hostname, disk, and CPU/GPU. It prints `lsblk` and requires `ERASE <disk>` before formatting:
```bash
./init.sh
```

The script asks for these values and writes them back to `nixos/host.nix`. Square brackets `[]` show the current value; press Enter to keep it. Parentheses `()` show valid choices.
```bash
User name [huzch]:
User email [huzch123@gmail.com]:
Host name [space]:
Target disk [/dev/nvme0n1]:
CPU (amd/intel) [amd]:
GPU (nvidia/amd/intel) [nvidia]:
```

| Priority | Item | What to verify |
| --- | --- | --- |
| P0 | `DISK` | Make sure it is not the USB installer, an external drive, or a disk with important data. |
| P1 | `GPU` / `USER_NAME` | GPU affects desktop startup. Username affects login and the home directory. |
| P2 | `CPU` / `HOST_NAME` | CPU affects microcode. Hostname affects the flake output name. |

After installation finishes, reboot. The script prepares `~/Documents/nix-dotfiles` and `~/Pictures/wallpapers`.

The installer supports checkpoint retries. To start over:
```bash
./init.sh --reset
```

### Shortcut Help
Niri does not show the shortcut overlay at startup (`skip-at-startup`). During daily use, press **`Super + Shift + /`** to open the shortcut cheatsheet.

---

## Project Structure
- **`flake.nix`**: System entry point.
- **`nixos/`**: System-level configuration.
  - `configuration.nix`: System settings, drivers, networking, fonts, and services.
  - `host.nix`: Current machine settings for username, email, hostname, disk, CPU, and GPU type.
  - `hardware-configuration.nix`: Machine-specific hardware config.
  - `disko.nix`: Partitioning layout.
- **`home/`**: Home Manager user-level configuration.
- **`dotfiles/`**: Niri, Noctalia, Neovim, and other app configs.

---

## Maintenance
Use `~/Documents/nix-dotfiles` as the source of truth.

### Install New Packages
- System components: edit `nixos/configuration.nix`.
- User apps: edit `home/app.nix` or another file under `home/`.

You can search for package names on [search.nixos.org](https://search.nixos.org/packages).

### Change Desktop Or App Config
- Niri compositor: edit `dotfiles/niri/config.kdl`, then run `niri msg action load-config-file` to hot-reload.
- Noctalia Shell: use the Settings panel (`Super + F2`) or open the launcher with `Super + Z` and search for settings.

### Apply Changes
If you only changed existing files under `dotfiles/`, you usually do not need a rebuild.

Run a rebuild after changing `.nix` files, packages, services, or Nix-managed files:
```bash
cd ~/Documents/nix-dotfiles

git add .
nh os switch    # preferred system management command (alias: nrs); equivalent to sudo nixos-rebuild switch --flake .#westwood
```

To update locked package versions, run:
```bash
nh os switch -u    # equivalent to nix flake update + nh os switch
```

---

## Why NixOS?

### Reproducible Versions
`flake.lock` records exact dependency revisions. Without `nix flake update`, package versions stay pinned.

### Generations And Rollback
Each `nixos-rebuild switch` creates a new generation. If it breaks, boot an older one.

### One Configuration, Repeatable Setup
System, user environment, desktop, and app config live in one repository.

---

## Feedback
Issues and pull requests are welcome.
