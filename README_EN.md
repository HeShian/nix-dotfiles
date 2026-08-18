[中文](README.md) | English

## Overview
![Desktop Screenshot](./doc/img/space.png)
![Fastfetch Screenshot](./doc/img/ff.png)

> Two NixOS Wayland sessions: Niri + Noctalia v5 is the default desktop, with Mango + Waybar/SwayNC/Rofi as an independent alternative.

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

  You can also override it at runtime with environment variables (the values in `init.sh` are just defaults):
  ```bash
  sudo http_proxy="http://192.168.42.129:7890" https_proxy="http://192.168.42.129:7890" ./init.sh
  ```

- **Stage 2: Installed NixOS system**
  After rebooting into the installed system, you can usually use a proxy client on the computer itself. Point the system proxy to localhost, not the phone gateway:
  ```nix
  # hosts/<host>/host.nix
  proxy = {
    default = "http://127.0.0.1:7890";
    noProxy = "127.0.0.1,::1,localhost";
  };
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

2. Run the installer and confirm username, email, hostname, disk, CPU/GPU, installed-system proxy, and SSH public key. It prints `lsblk` and requires `ERASE <disk>` before formatting:
```bash
./init.sh
```

The script asks for these values and writes them back to `hosts/<host>/host.nix`. Square brackets `[]` show the current value; press Enter to keep it. Parentheses `()` show valid choices.
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

| Priority | Item | What to verify |
| --- | --- | --- |
| P0 | `DISK` | Make sure it is not the USB installer, an external drive, or a disk with important data. |
| P1 | `GPU` / `USER_NAME` / SSH key | GPU affects desktop startup; username affects the home directory; a wrong key grants remote login. |
| P1 | Installed-system proxy | It must be reachable after the local proxy client starts, usually on `127.0.0.1`. |
| P2 | `CPU` / `HOST_NAME` | CPU affects microcode. Hostname affects the flake output name. |

After installation finishes, reboot. The script prepares `~/Documents/nix-dotfiles` and `~/Pictures/wallpapers`.

The installer supports checkpoint retries. A checkpoint is bound to the host, disk, user, and hardware parameters, and `/mnt` must belong to that disk. To start over, verify and unmount `/mnt` first, then run:
```bash
./init.sh --reset
```

### Shortcut Help
The greeter enters Niri by default; press **`F3`** to select Mango. In Niri, press **`Super + Shift + /`** for the shortcut overlay. See the [shortcut documentation](doc/en/shortcuts.md) for both sessions and their differences.

---

## Project Structure
- **`flake.nix`**: System entry point (flake-parts + den + treefmt-nix; wiring lives in `modules/flake/`).
- **`modules/flake/`**: flake-parts wiring layer. `hosts.nix` auto-discovers `hosts/*` and uses den to build each machine's `<host>`/`<host>-install` configurations; `schema.nix` declares typed metadata; `defaults.nix` holds global defaults; `install-tools.nix` exports the locked Disko app; `formatting.nix`/`checks.nix` provide formatting and static checks. See [doc/en/architecture.md](doc/en/architecture.md).
- **`hosts/aspire-a715/`**: Machine-specific configuration (one `hosts/<host>/` directory per machine; the directory name is the host name).
  - `host.nix`: Disk, CPU/GPU, primary user, proxy, and per-user permissions/email/SSH keys.
  - `default.nix`: Hardware/disko imports and `system.stateVersion`.
  - `hardware-configuration.nix`: Machine-specific hardware config.
  - `disko.nix`: Partitioning layout.
- **`modules/features/`**: Feature aspects (one file per feature, file name = aspect name; a file may carry both nixos and homeManager classes; the directory is auto-aggregated).
- **`dotfiles/`**: Niri, Noctalia, Mango companion components, Neovim, and other app configs.

---

## Maintenance
Use `~/Documents/nix-dotfiles` as the source of truth.

### Install New Packages
- System components: the nixos part of the matching file under `modules/features/`.
- User apps: edit `modules/features/apps.nix` (or the homeManager part of another feature).

You can search for package names on [search.nixos.org](https://search.nixos.org/packages).

### Change Desktop Or App Config
- Niri compositor: edit `dotfiles/niri/config.kdl`, then run `niri msg action load-config-file` to hot-reload.
- Noctalia Shell: use the Settings panel (`Super + F2`) or open the launcher with `Super + Z` and search for settings.
- Mango compositor: core settings live in `modules/features/mango.nix` and require a rebuild; Waybar/SwayNC/Rofi styling lives under `dotfiles/mango/` and only needs the matching `mango-*` user service restarted.

### Add a Feature Module, Host, Or User
The wiring structure (den aspects/includes, install variant) is documented in [doc/en/architecture.md](doc/en/architecture.md); step-by-step instructions are in the "Manual Maintenance Scenarios" table in [doc/en/maintenance.md](doc/en/maintenance.md).

### Apply Changes
If you only changed existing files under `dotfiles/`, you usually do not need a rebuild.

Run a rebuild after changing `.nix` files, packages, services, or Nix-managed files:
```bash
cd ~/Documents/nix-dotfiles

git add .
nh os switch    # preferred system management command (alias: nrs); equivalent to sudo nixos-rebuild switch --flake .#aspire-a715
```

To update locked package versions, run:
```bash
nh os switch -u    # equivalent to nix flake update + nh os switch
```

### Format Code
Use `nix fmt` for everything (treefmt: nixfmt/stylua/shfmt + deadnix/statix; config in `modules/flake/formatting.nix`). `nix flake check` also validates Niri, upstream `mango -p`, Mango JSON, and first-party shell scripts.

---

## Why NixOS?

### Reproducible Versions
`flake.lock` records exact dependency revisions. Without `nix flake update`, package versions stay pinned.

### Generations And Rollback
Each `nixos-rebuild switch` creates a new generation. If it breaks, boot an older one.

### One Configuration, Repeatable Setup
System, user environment, desktop, and app config live in one repository.

---

## Sources And References

- Forked from [huzch/nix-dotfiles](https://github.com/huzch/nix-dotfiles)
- Main reference: [SHORiN-KiWATA/shorin-arch-setup (noctalia-dotfiles)](https://github.com/SHORiN-KiWATA/shorin-arch-setup/tree/main/noctalia-dotfiles)
- Mango: [official Nix options](https://mangowm.github.io/docs/nix-options/); visual/component ideas adapted from [DreamMaoMao/mango-config](https://github.com/DreamMaoMao/mango-config)
- Animation reference: <https://lagrange-x.lanzouq.com/iQGv93sel3uf>

---

## Feedback
Issues and pull requests are welcome.
