This repository contains the NixOS config for all my hosts.
Heavily inspired by [Jappie's nix config](https://app.radicle.xyz/nodes/git.jappie.dev/rad:z4HEZGDPknT12W4fuXc6wM3HtYTf2) — thanks for the great reference!
## Repo structure
```
.
├── hosts       # config for all my hosts
├── modules     # custom NixOS modules for shared config
├── profiles    # opinionated config bundles for host classes
└── secrets     # encrypted secrets
```
## Hosts
- testnix: NixOS test VM (ext4)

## Profiles
Profiles are opinionated config bundles for specific host classes, exposed via `self.nixosProfiles`:
- `proxmox_vm`: Proxmox/QEMU virtual machine (virtio drivers, systemd-boot, qemu-guest-agent, disko)

## Secrets
Secrets are managed with [agenix](https://github.com/ryantm/agenix) + [agenix-rekey](https://github.com/oddlama/agenix-rekey). Secrets in the repo are encrypted with a master identity and automatically rekeyed per-host.

```sh
# Generate any secrets that have a generator defined (e.g. WireGuard keys)
nix run .#agenix-rekey.generate

# Rekey secrets for all hosts (required after adding secrets or changing host keys)
nix run .#agenix-rekey.rekey
```
# Deploy to a remote host
```sh
nix run nixpkgs#nixos-rebuild -- switch --flake .#testnix --target-host flufsor@10.0.120.60 --sudo --ask-sudo-password
```
