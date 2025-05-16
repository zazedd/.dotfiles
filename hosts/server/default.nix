{
  agenix,
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  user = "zazed";
in

{

  imports = [
    # agenix.darwinModules.default
    # ../../modules/asahi/secrets.nix
    ../../modules/server/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./trackmania.nix
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "xinho"; # Define your hostname.
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  time.timeZone = "Portugal";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.nix-ld.enable = true;

  # Setup user, packages, programs
  nix = {
    # package = pkgs.nixVersions.git;
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

  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      # ( this key is a one time key, and it has expired :) )
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kkKFmMyGGE11CNTRL-SpP3kvAjJwdP7iQ2Qyd4wdKqqQXjMWGZW
    '';
  };

  services.minecraft-servers = import ./minecraft.nix { inherit pkgs; };
  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    config = {
      adminpassFile = "/etc/nextcloud";
      dbtype = "sqlite";
    };
    # https = true;
  };

  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      # forceSSL = true;
      # enableACME = true;
      listen = [
        {
          addr = "127.0.0.1";
          port = 5252;
        }
      ];
    };

    "nc.ricardogoncalves" = {
      locations."/".proxyPass = "http://localhost:5252";
    };
    "nc.ricardogoncalves.burro-arctic.ts.net" = {
      # forceSSL = true;
      # enableACME = true;
      locations."/".proxyPass = "http://localhost:5252";
    };
  };

  # security.acme = {
  #   acceptTerms = true;
  #   certs = {
  #     ${config.services.nextcloud.hostName}.email = "leomendesantos@gmail.com";
  #   };
  # };

  services.firefly-iii = {
    inherit user;
    enable = true;
    enableNginx = true;
    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "/etc/nextcloud";
      SITE_OWNER = "mail@example.com";
      DB_CONNECTION = "mysql";
      DB_HOST = "db";
      DB_PORT = 3306;
      DB_DATABASE = "firefly";
      DB_USERNAME = "firefly";
      DB_PASSWORD_FILE = "/etc/nextcloud";
    };
  };

  # Load configuration that is shared across systems
  environment.systemPackages =
    with pkgs;
    [
      agenix.packages."${pkgs.system}".default
    ]
    ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [
      config.services.tailscale.port
      2350
      3450
    ];
    allowedTCPPorts = [
      5252 # nextcloud
      42069
      42068
      5900
      5901
      2350
      8008
    ];
  };

  system.stateVersion = "24.11";
}
