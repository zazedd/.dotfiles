{
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  user = "zazed";
  email = "leomendesantos@gmail.com";
  domain = "leoms.dev";
  ports = import ./ports.nix;
in
{
  imports = [
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix

    ../../modules/server/home-manager.nix
    ./services/tailscale.nix
    (import ./services/arr.nix { inherit ports; })
    (import ./services/homepage.nix { inherit config domain ports; })
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  nix = {
    settings.trusted-users = [
      "@admin"
      "${user}"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware.graphics.enable = true;
  hardware.amdgpu = {
    amdvlk.enable = true;
    initrd.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "xinho";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  time.timeZone = "Portugal";

  sops.defaultSopsFile = ../../secrets/server.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.age.generateKey = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.nix-ld.enable = true;

  ## Services

  sops.secrets."cloudflare-api" = { };
  security.acme = {
    defaults = {
      inherit email;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = config.sops.secrets."cloudflare-api".path;
      webroot = null;
    };
    acceptTerms = true;
    certs = {
      "ff.${domain}" = {
        domain = "*.${domain}";
        group = "nginx";
      };
    };
  };

  sops.secrets."minecraft-rcon" = { };
  systemd.services."minecraft-server-estupidos" = {
    serviceConfig.EnvironmentFile = config.sops.secrets."minecraft-rcon".path;
  };
  services.minecraft-servers = import ./services/minecraft.nix { inherit pkgs; };

  sops.secrets."firefly-api" = {
    owner = "firefly-iii";
    group = "nginx";
    mode = "777";
  };
  services.firefly-iii = import ./services/firefly.nix { inherit config email domain; };

  services.seafile = import ./services/seafile.nix { inherit email domain ports; };

  services.nginx = import ./services/nginx.nix { inherit ports domain; };

  ## Rest
  environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [
      config.services.tailscale.port
    ];
    allowedTCPPorts = [
      8082
      42069 # minecraft
      42068 # rcon minecraft
    ];
  };

  system.stateVersion = "24.11";
}
