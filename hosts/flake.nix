{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, sops-nix, ... }@inputs:
    let nodes = [ "homelab-0" "homelab-1" ];
    in {
      nixosConfigurations = builtins.listToAttrs (map (name: {
        name = name;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = { meta = { hostname = name; }; };
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./disko-config.nix
            ./hardware-configuration.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
          ];
        };
      }) nodes);
    };
}
