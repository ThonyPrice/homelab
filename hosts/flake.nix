{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs:
    let
      nodes = [
        "homelab-0" # 192.168.1.101"
        "homelab-1" # 192.168.1.102"
      ];
    in {
      nixosConfigurations = builtins.listToAttrs (map (name: {
        name = name;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = { meta = { hostname = name; }; };
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hardware-configuration.nix
            ./disko-config.nix
            ./configuration.nix
          ];
        };
      }) nodes);
    };
}
