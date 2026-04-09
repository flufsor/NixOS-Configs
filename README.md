This repository contains the NixOS config for all my hosts. I try to credit when
I copy code or take inspiration, feel free to reach out if you think I forgot
someone somewhere :)
## Repo structure
```
.
├── doc         # random notes / things I want to document
├── hosts       # config for all my hosts
├── images      # custom images for flashing NixOS configs
├── modules     # custom NixOS modules for shared config
├── secrets     # encrypted secrets
└── templates   # Nix templates
```
## Hosts
- testnix: NixOS test VM (ext4)

## Templates
Use `nix flake init -t $FLAKE#[template]`, e.g.
`nix flake init -t $FLAKE#devshell`.