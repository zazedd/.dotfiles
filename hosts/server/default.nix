{
  agenix,
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  user = "zazed";
  email = "leomendesantos@gmail.com";
  domain = "leoms.dev";
  server_name = "ricardogoncalves";
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
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "xinho";
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
    package = pkgs.nextcloud31;
    hostName = "localhost";
    config = {
      adminpassFile = "/etc/nextcloud";
      dbtype = "sqlite";
    };

    settings = {
      trusted_domains = [
        server_name
        domain
      ];
    };
    https = false;
  };

  services.firefly-iii = {
    inherit user;
    enable = true;
    enableNginx = true;
    virtualHost = "ff.${domain}";
    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "/etc/firefly";
      SITE_OWNER = email;
      DB_CONNECTION = "mysql";
      DB_HOST = "db";
      DB_PORT = 3306;
      DB_DATABASE = "firefly";
      DB_USERNAME = "firefly";
      DB_PASSWORD_FILE = "/etc/nextcloud";
    };
  };

  # TODO: add this to a config.os
  # options.services.nginx.virtualHosts = lib.mkOption {
  #   type = lib.types.attrsOf (
  #     lib.types.submodule (_: {
  #       sslCertificate = lib.mkDefault "/var/lib/acme/_.${domain}/fullchain.pem";
  #       sslCertificateKey = lib.mkDefault "/var/lib/acme/_.${domain}/key.pem";
  #     })
  #   );
  # };

  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 5252;
        }
      ];
    };

    "nc.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:5252";
    };

    "ff.${domain}" = {
      forceSSL = true;
      enableACME = true;
    };
  };

  security.acme = {
    defaults = {
      inherit email;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = "/etc/cloudflare/env";
      webroot = null;
    };
    acceptTerms = true;
    certs = {
      "nc.${domain}" = {
        domain = "*.${domain}";
        group = "nginx";
      };

      "ff.${domain}" = {
        domain = "*.${domain}";
        group = "nginx";
      };
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
      53 # adguard dns
      2350
      3450
    ];
    allowedTCPPorts = [
      5252 # nextcloud
      3003 # adguard
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
