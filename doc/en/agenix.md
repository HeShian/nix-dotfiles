[中文](../zh/agenix.md) | English

# agenix

Secrets management: ciphertext (`.age`) is committed in `secrets/`; plaintext is decrypted to `/run/agenix/` (tmpfs) at activation only — never on disk.

## How It Works

| Item | Notes |
|------|-------|
| Decryption key | Host SSH host key `/etc/ssh/ssh_host_ed25519_key` (set via `age.identityPaths`) |
| Recipients | In `secrets/secrets.nix`: `westwood` (host key, activation) and `claudia` (user `~/.ssh/id_ed25519`, CLI view/edit) |
| Declaration | `lib.genAttrs` list in `modules/nixos/secrets.nix`; add one line for a new secret |
| Reading | `owner = userName`; the user can read `/run/agenix/<name>` directly |

## Current Secrets

| Secret | Purpose |
|--------|---------|
| `deepseek_api_copilot` | VSCode Copilot custom endpoint |
| `deepseek_api_opencode` | opencode |
| `deepseek_api_pi` | pi-coding-agent |
| `github_token_codeberg` | GitHub PAT (ghp_ prefix) |

## Commands

Working directory must be `secrets/` (agenix reads rules from the sibling `secrets.nix`):

```bash
cd ~/Documents/nix-dotfiles/secrets

# Print plaintext
nix run github:ryantm/agenix -- -d <name>.age

# Edit (opens $EDITOR, re-encrypts on save)
nix run github:ryantm/agenix -- -e <name>.age

# Non-interactive write
echo -n "new value" | nix run github:ryantm/agenix -- -e <name>.age

# New secret: first register "<name>.age".publicKeys in secrets.nix, then run the line above

# After the host key changes (reinstall): re-encrypt everything with the new key
nix run github:ryantm/agenix -- -r
```

After modifying a `.age` file, run `nh os switch` to refresh `/run/agenix/` plaintext.

## After Reinstall

1. Prefer restoring the old host key to `/etc/ssh/` from backup (no re-encryption needed);
2. Otherwise generate a new host key, add its public key to `secrets/secrets.nix`, and `agenix -r` everything;
3. Restoring the user key `~/.ssh/id_ed25519` lets you decrypt on any machine.

## Offline Encryption

`nix run github:ryantm/agenix` downloads agenix. When the network is down, use the `age` binary already in the store (equivalent — agenix ciphertext is standard age format):

```bash
printf '%s\n%s\n' "<westwood pubkey>" "<claudia pubkey>" > /tmp/recipients.txt
echo -n "plaintext" | /nix/store/*-age-*/bin/age -R /tmp/recipients.txt -o <name>.age
rm /tmp/recipients.txt
```
