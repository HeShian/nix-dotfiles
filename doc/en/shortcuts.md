[中文](../zh/shortcuts.md) | English

# Shortcuts

Niri keybindings plus their Mango counterparts (`Mod` = Super). Niri comes from `dotfiles/niri/binds.kdl`; Mango comes from `dotfiles/mango/binds.conf`. `Mod+Shift+/` opens the searchable overlay in both sessions.

## Special

| Key | Action |
|-----|--------|
| `Mod+Shift+/` | Keybinding cheat sheet |
| `Mod+F1` | Restart the input method (`fcitx5 -r`) |
| `Mod+F2` | Noctalia settings |
| `Mod+P` | Pick window info / color |
| `Mod+Escape` | Toggle shortcut inhibit (full keyboard to VM/remote) |

## Launchers

| Key | Action |
|-----|--------|
| `Mod+Return` / `Mod+T` | Terminal (foot) |
| `Mod+/` | Quick terminal (drop-down) |
| `Mod+B` / `Mod+Alt+B` | Zen Browser / Brave |
| `Mod+E` | File manager (Thunar) |
| `Mod+Alt+O` | opencode (AI agent) |

## Noctalia Panels

| Key | Action |
|-----|--------|
| `Mod+Z` | App launcher |
| `Mod+Space` | Control center |
| `Mod+Alt+W` | Wallpaper picker |
| `Mod+Shift+N` | Notifications |
| `Mod+Shift+P` | Power menu |
| `Mod+Alt+V` | Clipboard history |
| `Alt+Tab` | Window switcher |
| `Mod+F10` / `Mod+Shift+F10` | Random wallpaper / download random wallpaper |
| `Mod+Alt+L` / `Mod+Alt+P` | Lock screen / lock and suspend |

## Windows and Overview

| Key | Action |
|-----|--------|
| `Mod+O` / `Mod+G` | Overview |
| `Mod+Q` | Close window |
| `Alt+F4` / `Alt+Shift+F4` | Force kill window / kill process tree |
| `Mod+Shift+E` | Quit niri |
| `Mod+Tab` / `Mod+Shift+Tab` | Switch windows with previews (workspace) |
| `Mod+grave` | Switch windows of the same app |

## Focus and Movement

| Key | Action |
|-----|--------|
| `Mod+H/J/K/L` (or arrows) | Focus left/down/up/right |
| `Mod+Home` / `Mod+End` | Focus first / last column |
| `Mod+Ctrl+H/J/K/L` | Move column/window |
| `Mod+Shift+H/J/K/L` | Focus other monitor |
| `Mod+Shift+Ctrl+H/J/K/L` | Move column to other monitor |
| `Mod+Shift+Alt+H/J/K/L` | Move workspace to other monitor |

## Workspaces

| Key | Action |
|-----|--------|
| `Mod+U` / `Mod+I` | Previous / next workspace |
| `Mod+1-0` | Go to workspace 1-10 |
| `Mod+Ctrl+U/I` (or `Mod+Ctrl+1-0`) | Move column to workspace |
| `Mod+Shift+U/I` | Move whole workspace |

## Layout

| Key | Action |
|-----|--------|
| `Mod+A` / `Mod+D` | Consume/expel window between columns |
| `Mod+Shift+X` | Tabbed column display |
| `Mod+R` / `Mod+Shift+R` | Preset width / height |
| `Mod+F` / `Mod+Alt+F` | Maximize / fullscreen |
| `Mod+C` | Center column |
| `Mod+-` / `Mod+=` | Width ±5% (add Shift for height) |
| `Mod+V` / `Mod+N` | Toggle floating / switch floating-tiling focus |

## Screenshots and Media

| Key | Action |
|-----|--------|
| `Print` / `Ctrl+Print` / `Shift+Print` | Region / window / monitor screenshot |
| `Mod+Shift+S` | Region screenshot and annotate (satty) |
| `XF86Audio*` | Volume / playback |
| `XF86MonBrightness*` | Brightness |

## Mango Shortcuts

| Key | Action |
|-----|--------|
| `Mod+Return` / `Mod+T` / `Mod+/` | Shared Foot / quick terminal |
| `Mod+Shift+/` / `Mod+F1` | Shortcut overlay / restart input method |
| `Mod+F2` | Noctalia settings |
| `Mod+Z` / `Mod+Space` / `Mod+Shift+P` | Noctalia launcher / control center / session panel |
| `Mod+Shift+N` / `Mod+Alt+V` | Noctalia notifications / clipboard history |
| `Mod+Alt+W` / `Mod+F10` / `Mod+Shift+F10` | Wallpaper panel / random wallpaper / download random wallpaper |
| `Alt+Tab` | Noctalia window switcher |
| `Mod+O` / `Mod+G` / `Mod+Q` | Overview / overview / close window |
| `Mod+V` / `Mod+F` / `Mod+Alt+F` | Float / maximize / fullscreen |
| `Mod+C` | Center a floating window |
| `Mod+H/J/K/L` (or arrows) | Focus left/down/up/right |
| `Mod+Ctrl+H/J/K/L` (or WASD/arrows) | Exchange with the window in that direction |
| `Mod+Shift+H/J/K/L` / `Mod+Shift+Ctrl+H/J/K/L` | Focus another monitor / send window to another monitor |
| `Mod+U/I` (or PageDown/PageUp) / `Mod+Ctrl+U/I` | View adjacent occupied tag / send window to adjacent tag |
| `Mod+1-9` / `Mod+Ctrl+1-9` | View tag / send window to tag |
| `Mod+R` / `Mod+Alt+R` | Scroller proportion preset / cycle tile, scroller, dwindle |
| `Mod+-` / `Mod+=` | Tile master ratio ±5% |
| `Print` / `Ctrl+Print` / `Shift+Print` / `Mod+Shift+S` | Region / focused window / current monitor / annotated-region screenshot |
| `Mod+Alt+L` / `Mod+Alt+P` | Lock / lock and suspend |
| `Mod+Shift+R` / `Mod+Shift+E` | Reload config / quit Mango |

## Mango vs Niri

Mango uses fixed tags 1–9, all defaulting to `tile`; Niri uses dynamic workspaces 1–10. Mango has no stable equivalents for Niri's consume/expel column operations, whole-column operations, or `recent-windows` same-app filtering, so those are intentionally unbound. Both sessions share Noctalia panels, notifications, window switcher, clipboard, lock screen, screenshots, wallpaper downloads, and idle policy; compositor-specific capabilities do not get misleading approximate bindings.
