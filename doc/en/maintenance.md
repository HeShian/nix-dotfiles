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
| GUI/CLI packages | `modules/features/apps.nix` / `modules/features/desktop.nix` / `modules/features/shell.nix` (homeManager part) |
| System components | The nixos part of the matching file in `modules/features/` |
| New app config dir | `dotfiles/<name>/` (register in `configs` in `modules/features/dotfiles.nix`) |
| Machine parameters | Always via `hosts/<host>/host.nix`, never hardcode |

## Manual Maintenance Scenarios

| Scenario | Steps |
|----------|-------|
| Add a feature module | Add a file under `modules/features/` (file name = aspect name; auto-aggregated) → add its name to `hostFeatureNames` or `userFeatureNames` in `modules/flake/hosts.nix`; if a host feature is regular-system-only, also add it to `installExcludedFeatureNames` |
| Add a host | Copy `hosts/aspire-a715/` to `hosts/<new-name>/`, edit `host.nix` and generate `hardware-configuration.nix`; for a brand-new machine just use `init.sh` |
| Add a user | Add `users.<name> = { email = ...; isAdmin = ...; sshAuthorizedKeys = [ ... ]; };` in `hosts/<host>/host.nix`; set `primaryUser = "<name>"` only when that user is primary |
| Change machine parameters | Edit `hosts/<host>/host.nix`; `cpu`/`gpu` values are constrained by the `den.schema.host` enums (amd/intel, nvidia/amd/intel), and a misspelled attribute fails at the wiring layer |
| Upgrade a single flake input | `nix flake update <name>` (e.g. when noctalia releases) |
| Verify changes | For a new Nix file, first run `git add -N <file>` → `nix fmt` → `nix flake check` (includes ShellCheck) → `nh os build`, then `nrs` |

Read [Architecture](architecture.md) before changing feature wiring or assembly logic.

## Caveats

| Item | Notes |
|------|-------|
| Formatting | Always use `nix fmt` (treefmt: nixfmt/stylua/shfmt + deadnix/statix; config in `modules/flake/formatting.nix`); kitsfmt is no longer used in this repo |
| Secrets | After changing `secrets/`, run `nh os switch` to refresh `/run/agenix/` plaintext |
