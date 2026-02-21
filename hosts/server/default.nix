{
  config,
  pkgs,
  my_nixpkgs,
  lib,
  ...
}@inputs:

let
  user = "zazed";
  email = "leomendesantos@gmail.com";
  domain = "leoms.dev";
  my_pkgs = import my_nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/teamspeak6
    (import ../../modules/reverse-proxy { inherit config domain lib; })

    ../../profiles/shared
    ../../profiles/shared/cachix
    ../../profiles/server/home-manager.nix

    (import ./services/arr.nix { inherit config; })
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg: true;
    };
    overlays = [
      inputs.nix-minecraft.overlay
      inputs.copyparty.overlays.default
    ];
  };

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
    initrd.enable = true;
    opencl.enable = true;
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

  # services

  ## secrets
  sops.secrets = {
    "cloudflare-api" = { };
    "vaultwarden-env" = { };
    "minecraft-rcon" = { };
    "copyparty-${user}" = {
      owner = "copyparty";
    };
    "paperless" = {
      owner = "paperless";
    };
    "immich-secrets" = { };
    "glance-env" = { };
  };

  systemd.services.glance.serviceConfig.EnvironmentFile =
    lib.mkForce
      config.sops.secrets."glance-env".path;

  ## users and groups
  users.groups.cloud = { };

  users.users.copyparty = {
    description = "Service user for copyparty";
    group = "cloud";
    isSystemUser = true;
  };

  users.users.paperless = {
    description = "Service user for paperless-ngx";
    group = lib.mkForce "cloud";
    isSystemUser = true;
  };

  ## proxies
  my.reverse-proxy = {
    jellyfin = {
      port = 8096;
      aliases = [ "watch" ];
      extraLocations = {
        "/socket" = {
          proxyPass = "http://127.0.0.1:${toString config.my.reverse-proxy.jellyfin.port}/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
      };
    };

    jellyseerr = {
      port = 5055;
      aliases = [ "request" ];
    };

    immich = {
      port = 2283;
      aliases = [ "photos" ];
    };

    copyparty = {
      port = 3210;
      aliases = [ "cloud" ];
    };

    copyparty_webdav = {
      port = 3211;
      public = false;
    };

    radarr.port = 7878;
    sonarr.port = 8989;
    lidarr.port = 8686;
    prowlarr.port = 9696;
    bazarr.port = 6767;

    sabnzbd.port = 8080;
    deluge.port = 5000;

    bitwarden.port = 8222;
    actual.port = 8282;
    paperless.port = 7999;
    home.port = 5050;
  };

  ## services
  services.glance = import ./services/homepage.nix { inherit config domain; };
  services.vaultwarden = import ./services/vaultwarden.nix { inherit config domain; };
  services.actual = import ./services/actual.nix { inherit config; };
  services.copyparty = import ./services/copyparty.nix { inherit user config; };
  services.paperless = import ./services/paperless.nix { inherit config; };
  services.immich = import ./services/immich.nix { inherit config; };
  services.teamspeak6 = {
    enable = true;
    openFirewall = true;
    package = pkgs.callPackage ../../pkgs/teamspeak6/default.nix { };
  };

  ###
  security.acme = {
    acceptTerms = true;
    certs = {
      "ff.${domain}" = {
        inherit email;
        domain = "*.${domain}";
        group = "nginx";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.secrets."cloudflare-api".path;
        webroot = null;
      };
    };
  };

  environment.systemPackages = import ../../profiles/shared/packages.nix { inherit pkgs; };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [
      config.services.tailscale.port
    ];
    allowedTCPPorts = [
      5005
      config.my.reverse-proxy.copyparty.port
      config.my.reverse-proxy.copyparty_webdav.port
    ];
  };

  system.stateVersion = "25.05";
}
