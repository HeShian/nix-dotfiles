[中文](../zh/maintenance.md) | English

# Maintenance

Daily maintenance, upgrades, and rollback. The preferred command is `nh` (its flake already points at this repo and escalates privileges itself).

## Commands

| Command | Purpose |
|---------|---------|
| `nrs` (= `nh os switch`) | Apply `.nix` changes, switch generation |
| `nh os build` | Build only, no switch (preferred verification) |
| `nix flake update` | Upgrade all flake inputs |
| `nix flake update <name>` | Upgrade one flake input only |
| `nh os switch -u` | Upgrade inputs and apply |
| `niri msg action load-config-file` | Hot-reload Niri config |
| `niri validate` | Validate Niri config |
| `mmsg dispatch reload_config` | Hot-reload the generated config inside Mango |
| `systemctl --user status mango-session.target` | Inspect the Mango session target and components |
| `journalctl --user -b -u 'mango-*'` | Read Mango component logs for this boot |

## No Rebuild Needed

`dotfiles/` is live-linked to the repo; changes take effect after restarting or reloading the app — no rebuild.

## Automatic Maintenance

| Item | Mechanism |
|------|---------|
| Generation cleanup | nh clean runs daily (keeps latest 3 + last 7 days) |
| Flatpak | Daily auto-update (`onActivation=false`, never blocks rebuild) |
| AI skills | nixkits `skills/` linked to `~/.agents/skills/`, updated via `nix flake update` |

## Rollback

If Mango misbehaves, log out and press `F3` in the greeter to select Niri; Niri remains the default. For a system-level regression, pick an older generation in GRUB. A broken new generation never affects old ones.

## Maintaining the Mango Session

| Item | Operation or expected state |
|------|-----------------------------|
| Core config | Edit `modules/features/mango.nix`, run `nix flake check`, then rebuild; the upstream HM module validates generated `config.conf` with `mango -p` |
| Component styling | Edit `dotfiles/mango/{waybar,swaync,rofi,wlogout,foot}/`, then restart the matching `mango-*` user service |
| Idle policy | Lock at 10 minutes, power off `eDP-1` at 15, suspend at 30; input resume wakes the display through `mmsg` |
| Runtime acceptance | `echo "$XDG_CURRENT_DESKTOP"` should print `mango`; `systemctl --user is-active mango-session.target mango-waybar.service mango-swaync.service` should all be `active` |
| Exit acceptance | After logout, `mango-session-guard` stops the target; from Niri, `systemctl --user is-active mango-session.target` should report `inactive` |
| Portal | For screenshot/screen-sharing failures inspect `systemctl --user status xdg-desktop-portal.service` and the user journal; upstream's NixOS module owns Mango's wlr/gtk routing |

## Where Changes Go

| Change | Location |
|--------|----------|
| GUI/CLI packages | `modules/features/apps.nix` / `modules/features/desktop.nix` / `modules/features/{niri,mango}.nix` / `modules/features/shell.nix` |
| System components | The nixos part of the matching file in `modules/features/` |
| New app config dir | Register shared directories in `modules/features/dotfiles.nix`; compositor-specific directories are linked by `niri.nix` / `mango.nix` |
| Machine parameters | Always via `hosts/<host>/host.nix`, never hardcode |

## Manual Maintenance Scenarios

| Scenario | Steps |
|----------|-------|
| Add a feature module | Add a file under `modules/features/` (file name = aspect name; auto-aggregated) → add its name to `hostFeatureNames` or `userFeatureNames` in `modules/flake/hosts.nix`; if a host feature is regular-system-only, also add it to `installExcludedFeatureNames` |
| Add a host | Copy `hosts/aspire-a715/` to `hosts/<new-name>/`, edit `host.nix` and generate `hardware-configuration.nix`; for a brand-new machine just use `init.sh` |
| Add a user | Add `users.<name> = { email = ...; isAdmin = ...; sshAuthorizedKeys = [ ... ]; };` in `hosts/<host>/host.nix`; set `primaryUser = "<name>"` only when that user is primary |
| Change machine parameters | Edit `hosts/<host>/host.nix`; `cpu`/`gpu` values are constrained by the `den.schema.host` enums (amd/intel, nvidia/amd/intel), and a misspelled attribute fails at the wiring layer |
| Upgrade a single flake input | `nix flake update <name>` (e.g. when noctalia releases) |
| Verify changes | For a new Nix file, first run `git add -N <file>` → `nix fmt` → `nix flake check` (Niri, `mango -p`, JSON, ShellCheck) → `nh os build`, then `nrs` |

Read [Architecture](architecture.md) before changing feature wiring or assembly logic.

## Caveats

| Item | Notes |
|------|-------|
| Formatting | Always use `nix fmt` (treefmt: nixfmt/stylua/shfmt + deadnix/statix; config in `modules/flake/formatting.nix`); kitsfmt is no longer used in this repo |
| Secrets | After changing `secrets/`, run `nh os switch` to refresh `/run/agenix/` plaintext |
