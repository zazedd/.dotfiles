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
  server_name = "ricardogoncalves";
  ports = import ./ports.nix;
in
{
  imports = [
    # ../../modules/asahi/secrets.nix
    ../../modules/server/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix
    ./arr.nix
    (import ./homepage.nix { inherit config domain; })
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

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

  sops.secrets."minecraft-rcon" = { };
  systemd.services."minecraft-server-estupidos".serviceConfig.EnvironmentFile =
    config.sops.secrets."minecraft-rcon".path;
  services.minecraft-servers = import ./minecraft.nix { inherit pkgs; };

  services.seafile = {
    enable = true;

    adminEmail = email;
    initialAdminPassword = "pass";

    ccnetSettings.General.SERVICE_URL = "https://cloud.${domain}";
    seafileSettings = {
      history.keep_days = "14";
      fileserver = {
        host = "127.0.0.1";
        port = ports.seafile;
      };
    };
    seahubExtraConf = ''
      DEBUG = True
      CSRF_TRUSTED_ORIGINS = ["https://cloud.${domain}"]
    '';
  };

  services.nginx =
    let
      mkProxy =
        name:
        let
          port = toString ports.${name};
        in
        {
          name = "${name}.${domain}";
          value = {
            forceSSL = true;
            sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
            sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
            locations."/".proxyPass = "http://127.0.0.1:${port}/";
          };
        };
    in
    {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts =
        {
          "cloud.${domain}" = {
            forceSSL = true;
            # enableACME = true;
            sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
            sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
            locations = {
              "/" = {
                proxyPass = "http://unix:/run/seahub/gunicorn.sock";
                extraConfig = ''
                  proxy_set_header Host cloud.${domain};
                  proxy_set_header   X-Real-IP $remote_addr;
                  proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header   X-Forwarded-Host $server_name;
                  proxy_read_timeout  1200s;
                  client_max_body_size 0;
                '';
              };
              "/seafhttp" = {
                proxyPass = "http://127.0.0.1:8082/";
                extraConfig = ''
                  rewrite ^/seafhttp(.*)$ $1 break;
                  client_max_body_size 0;
                  proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_connect_timeout  36000s;
                  proxy_read_timeout  36000s;
                  proxy_send_timeout  36000s;
                  send_timeout  36000s;
                '';
              };
            };
          };

          "ff.${domain}" = {
            forceSSL = true;
            enableACME = true;
          };
        }
        // builtins.listToAttrs (
          map mkProxy [
            "radarr"
            "sonarr"
            "prowlarr"
            "deluge"
            "sabnzbd"
            "flaresolverr"
            "jellyfin"
            "watch" # also points to jellyfin
            "jellyseerr"
            "request" # also points to jellyseerr
            "bazarr"
            "home"
          ]
        );
    };

  sops.secrets."firefly-api" = {
    owner = "firefly-iii";
    group = "nginx";
    mode = "777";
  };

  services.firefly-iii = {
    # inherit user;
    enable = true;
    enableNginx = true;
    virtualHost = "ff.${domain}";
    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = config.sops.secrets."firefly-api".path;
      SITE_OWNER = email;
    };
  };

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
  environment.systemPackages = (import ../../modules/shared/packages.nix { inherit pkgs; });

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
