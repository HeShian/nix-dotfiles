[中文](../zh/software.md) | English

# Software

Categorized software list. Declarations live in `modules/features/` (`apps.nix` daily apps, `desktop.nix` shared desktop base, `niri.nix`/`mango.nix` session stacks, `shell.nix` terminal tools, and `flatpak.nix` Flatpak).

## Desktop Sessions

| Session | Compositor | Shared shell | Login behavior |
|---------|------------|--------------|----------------|
| Niri | Niri | Noctalia v5: bar/launcher/control center/notifications/clipboard/lock/wallpaper/OSD/idle | Select with `F3`; the greeter remembers it |
| Mango | Mango (tile/scroller/dwindle) | The same Noctalia v5 config and runtime state | Select with `F3`; the greeter remembers it |

Under `mango-session.target`, Mango starts Noctalia, fcitx5, udiskie, xsettingsd, the portal-theme and screenshot-sound watchers, persistent clipboard, text/image cliphist, delayed random wallpaper, Gopeed, and XWayland DPI. The guard stops them together on logout. Noctalia itself provides Polkit, network/Bluetooth UI, notifications, and idle policy.

## Daily Apps

| Category | Software |
|----------|----------|
| Browsers | zen-twilight (pywalfox-native follows the palette), brave |
| IM/Meetings | telegram-desktop, discord, qq, wechat, wemeet (via wemeet-xwayland wrapper) |
| Notes/Reading | obsidian, z-library-desktop, readest |
| Office | wpsoffice-cn (WPS 365, see font note below), onlyoffice-desktopeditors |
| Development | Codex Desktop (unofficial Linux wrapper) + codex CLI, vscode, opencode, pi-coding-agent, kimi-code, dsh (DeepSeek Harness, `dsh web` starts the Web UI), uv, python3 |
| Creation | obs-studio, krita, mazi51 (51mazi novel editor) |
| Network tools | flclash (proxy), gopeed (download), localsend (LAN transfer), go-musicfox (NetEase), remmina (RDP) |
| Gaming | gamescope, prismlauncher (Minecraft), protonplus, lutris, heroic |
| Wine/Containers | wine (stableFull), winetricks, waydroid-helper |

**WPS missing fonts**: corefonts (Arial/Times New Roman/Courier New etc.) and vista-fonts (Calibri etc.) are installed system-wide; SimSun (宋体), SimHei (黑体), Wingdings and Symbol are not redistributable — manually copy `simsun.ttc`, `simhei.ttf`, `wingding.ttf`, `symbol.ttf` (optionally `simfang.ttf`/`simkai.ttf`/`msyh.ttc`) from `C:\Windows\Fonts\` on any Windows machine into `~/.local/share/fonts/`, then run `fc-cache -f`.

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
| Betterbird | Email |
| Bottles | Windows app containers |
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
| rtk | Compress command output to reduce AI-agent token use |
| codegraph | Code knowledge graph and MCP index |
| nodejs | npm/npx runtime and CLI dependency |
