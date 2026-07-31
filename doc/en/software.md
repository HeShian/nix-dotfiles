[中文](../zh/software.md) | English

# Software

Categorized software list. Declared in: `home/app.nix` (daily apps), `home/desktop.nix` (desktop tools), `home/shell.nix` (terminal tools), `nixos/modules/desktop.nix` (system modules), `nixos/modules/flatpak.nix` (Flatpak).

## Daily Apps

| Category | Software |
|----------|----------|
| Browsers | zen-twilight (pywalfox-native follows the palette), brave |
| IM/Meetings | telegram-desktop, discord, qq, wechat, wemeet (via wemeet-xwayland wrapper) |
| Notes/Reading | obsidian, z-library-desktop, readest |
| Development | vscode, opencode, pi-coding-agent, kimi-code, kitsfmt, uv, python3 |
| Creation | obs-studio, krita |
| Network tools | gopeed (download), localsend (LAN transfer), go-musicfox (NetEase), remmina (RDP) |
| Gaming | gamescope, prismlauncher (Minecraft), protonplus, lutris, heroic |
| Wine/Containers | wine (stableFull), winetricks, waydroid-helper |

## System Modules

| Software | Notes |
|----------|-------|
| steam | System module provides udev rules and Remote Play ports |
| kdeconnect | System module opens firewall ports automatically |
| Thunar | File manager (archive/volume plugins, gvfs trash, tumbler thumbnails) |

## Flatpak

| Software | Purpose |
|----------|---------|
| Flatseal | Flatpak permission manager |
| WPS 365 | Office suite |
| Betterbird | Email |
| Bottles | Windows app containers |
| Wonderpen | Writing (bypasses document portal, direct host dir) |
| Baidu NetDisk | Cloud storage |

## Desktop Tools

| Category | Software |
|----------|----------|
| Screenshot/Record | grim, slurp, wf-recorder, satty (annotate) |
| Clipboard | cliphist, wl-clipboard, wl-clip-persist |
| Media | imv (images), mpv, mpvpaper (video wallpaper), cava, pwvucontrol, playerctl |
| System tools | brightnessctl, udiskie, fuzzel (launcher), libnotify, file-roller, imagemagick |
| Misc | xsettingsd, sunsetr (night light), sound-theme-freedesktop, xprop/file |

## Terminal Tools

| Software | Purpose |
|----------|---------|
| yazi | File manager (`y` cds into the last directory on exit) |
| neovim | Editor (config in `dotfiles/nvim/`) |
| lazygit | git TUI |
| fastfetch / btop | System info / resource monitor |
