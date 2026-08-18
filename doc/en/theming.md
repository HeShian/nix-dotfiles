[中文](../zh/theming.md) | English

# Theming

The Niri/Noctalia color pipeline: wallpaper → palette → templates rendered into every app. Mango uses a separate static deep-brown Gruvbox theme and does not read Noctalia runtime state.

## Pipeline

| Stage | Notes |
|-------|-------|
| Extraction | Noctalia generates a palette from the current wallpaper (matugen) |
| Rendering | Templates in `dotfiles/noctalia/templates/` produce per-app colors |
| Hot reload | Apps recolor instantly via include/signals/hooks — no restarts |

## Templates

| Target | Mechanism |
|--------|-----------|
| foot | Generates `~/.config/foot/themes/noctalia`, included by the main config (seeded fallback if missing) |
| neovim | Generates colors.lua, hot-reloaded via SIGUSR1 (falls back to Catppuccin Mocha) |
| GTK icons | Adwaita recolored to `Adwaita-Matugen-{A,B}`; A/B alternation forces refresh |
| GTK/Qt colors | Taken over by Noctalia templates (HM gtk module intentionally unused) |
| zen browser | pywalfox template + pywalfox-native |
| fcitx5 popup | Generates the noctalia theme; `fcitx5 -r` in `post_hook` replaces seamlessly |
| Dark/light | `portal-watcher.sh` syncs via gsettings |

## Operations

| Action | How |
|--------|-----|
| Recolor via wallpaper | `Mod+F10` random switch, palette regenerates automatically |
| Download online wallpaper | `Mod+Shift+F10` |
| Manual color/wallpaper | `Mod+Alt+W` wallpaper panel, control center |
| Dark/light toggle | Control center (everything above follows automatically) |

## Config Seeding

`~/.config/noctalia` is not in git (runtime state). The Niri feature's `home.activation.niriSeeds` seeds it from `dotfiles/noctalia/` **only when missing** (including the offline community palette cache). To update the seed, sync back manually per `dotfiles/noctalia/README.md`.
