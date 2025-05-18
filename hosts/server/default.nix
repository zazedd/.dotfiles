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

  services.seafile = {
    enable = true;

    adminEmail = "admin@example.com";
    initialAdminPassword = "change this later!";

    ccnetSettings.General.SERVICE_URL = "http://cloud.${domain}";
    seafileSettings = {
      history.keep_days = "14";
      fileserver = {
        host = "127.0.0.1";
        port = 8082;
      };
    };
    seahubExtraConf = ''
      DEBUG = True
      CSRF_TRUSTED_ORIGINS = ["cloud.${domain}"]
    '';
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "cloud.${domain}" = {
        forceSSL = true;
        # enableACME = true;
        sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
        locations = {
          "/".proxyPass = "http://unix:/run/seahub/gunicorn.sock";
          "/seafhttp".proxyPass = "http://127.0.0.1:8082/";
        };
      };

      "ff.${domain}" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  services.firefly-iii = {
    inherit user;
    enable = false;
    enableNginx = true;
    virtualHost = "ff.${domain}";
    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = "/etc/firefly/api";
      SITE_OWNER = email;
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
      # "cloud.${domain}" = {
      #   domain = "*.${domain}";
      #   group = "nginx";
      # };

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
    ];
    allowedTCPPorts = [
      8082
      42069 # minecraft
      42068 # rcon minecraft
    ];
  };

  system.stateVersion = "24.11";
}
