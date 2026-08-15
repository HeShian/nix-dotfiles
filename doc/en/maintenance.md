[中文](../zh/maintenance.md) | English

# Maintenance

Daily maintenance, upgrades, and rollback. The preferred command is `nh` (its flake already points at this repo and escalates privileges itself).

## Commands

| Command | Purpose |
|---------|---------|
| `nrs` (= `nh os switch`) | Apply `.nix` changes, switch generation |
| `nh os build` | Build only, no switch (preferred verification) |
| `nix flake update` | Upgrade all flake inputs |
| `nh os switch -u` | Upgrade inputs and apply |
| `niri msg action load-config-file` | Hot-reload Niri config |
| `niri validate` | Validate Niri config |

## No Rebuild Needed

`dotfiles/` is live-linked to the repo; changes take effect after restarting or reloading the app — no rebuild.

## Automatic Maintenance

| Item | Mechanism |
|------|---------|
| Generation cleanup | nh clean runs daily (keeps latest 3 + last 7 days) |
| Flatpak | Daily auto-update (`onActivation=false`, never blocks rebuild) |
| AI skills | nixkits `skills/` linked to `~/.agents/skills/`, updated via `nix flake update` |

## Rollback

Pick an older generation in the GRUB boot menu. A broken new generation never affects old ones.

## Where Changes Go

| Change | Location |
|--------|----------|
| GUI/CLI packages | `modules/home/app.nix` / `modules/home/desktop.nix` / `modules/home/shell.nix` |
| System components | Matching topic file in `modules/nixos/` |
| New app config dir | `dotfiles/<name>/` (register in `configs` in `modules/home/default.nix`) |
| Machine parameters | Always via `hosts/<host>/host.nix`, never hardcode |

## Caveats

| Item | Notes |
|------|-------|
| Formatting | Always use `nix fmt` (treefmt: nixfmt/stylua/shfmt + deadnix/statix; config in `modules/flake/formatting.nix`); kitsfmt is no longer used in this repo |
| Secrets | After changing `secrets/`, run `nh os switch` to refresh `/run/agenix/` plaintext |
