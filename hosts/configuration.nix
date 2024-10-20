{ config, lib, pkgs, meta, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  sops.defaultSopsFile = ./../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/homelab" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.k3s-token = { };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.openssh.enable = true;

  networking.hostName = meta.hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = "/run/secrets/k3s-token";
    extraFlags = toString ([
      ''--write-kubeconfig-mode "0644"''
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ] ++ (if meta.hostname == "homelab-0" then
      [ ]
    else
      [ "--server https://homelab-0:6443" ]));
    clusterInit = (meta.hostname == "homelab-0");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thony = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ tree ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG6r+a1SqfwK48W8AaZZlBLQvs2iTAyV8zsb5wJZLC6 thonyprice@gmail.com"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG6r+a1SqfwK48W8AaZZlBLQvs2iTAyV8zsb5wJZLC6 thonyprice@gmail.com"
  ];

  environment.systemPackages = with pkgs; [
    git
    k3s
    neovim
    cifs-utils
    nfs-utils
  ];

  system.stateVersion = "24.05";
}
