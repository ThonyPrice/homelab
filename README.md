# Homelab

## Host Machines Setup

Currently, I run a two node cluster where each node runs NixOS.
I use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere/tree/main) to provision NixOS on the host machines.
I followed the  nixos-anywhere [quickstart guide](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md) to derive my initial config which has been extended over time.
The prerequisites are strictly inherited from `nixos-anywhere`, refer to its [documentation](https://github.com/nix-community/nixos-anywhere/tree/main?tab=readme-ov-file#prerequisites).

## Bootstrapping

### Provision Node 1

To provision my first node with NixOS, I run:

``` bash
nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config ./hosts/hardware-configuration.nix \
    --flake ./hosts#homelab-0 nixos@192.168.1.101
```

It _will_ fail once with an error like
``` bash
error: getting status of '/nix/store/fl4s59q-source/hosts/hardware-configuration.nix': No such file or directory
```
keep calm and just `git add ./hosts/harware-configuration.nix`. 
The generated file needs to be checked in to complete the flake command, so repeat the `nix run` command. 

**SSH Access**

When connecting to the node over SSH the first time you may run into:
``` bash
$ ssh -i ~/.ssh/homelab-thony root@homelab-0

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:xsBwvno4BzeGJb5PIdw73+5wE9EPj/PVjmqUuJ8hmRE.
Please contact your system administrator.
Add correct host key in /home/thony/.ssh/known_hosts to get rid of this message.
Offending ED25519 key in /home/thony/.ssh/known_hosts:33
Host key for homelab-0 has changed and you have requested strict checking.
Host key verification failed.
```
It's fine, just reset host with `ssh-keygen -R homelab-0` to resolve it. 

### Provision Node 2,...,N

Provision node _N_ by:
``` bash
nix run github:nix-community/nixos-anywhere -- \
    --flake ./hosts#homelab-1 nixos@192.168.1.102
```

## Manage Nodes

Post bootstrapping, any changes to a node _N_ will be applied by:

``` bash
nixos-rebuild switch --flake ./hosts#homelab-<N> --target-host root@homelab-<N>
``
