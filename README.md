# Homelab

## Host Machines Setup

Currently, I run a two node cluster where each node runs NixOS.
I use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere/tree/main) to provision NixOS on the host machines.
I followed the  nixos-anywhere [quickstart guide](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md) to derive my initial config which has been extended over time.
The prerequisites are strictly inherited from `nixos-anywhere`, see its [documentation](https://github.com/nix-community/nixos-anywhere/tree/main?tab=readme-ov-file#prerequisites).

## Bootstrapping

To provision machine with NixOS, I run:

``` bash
SSH_PRIVATE_KEY="$(cat ~/.ssh/homelab-thony)"$'\n';
nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config .hosts/hardware-configuration.nix \
    --extra-files ~/.ssh/homelab-thony \
    --flake ./hosts#homelab-0 root@192.168.1.101
```

