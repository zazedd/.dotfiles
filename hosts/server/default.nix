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

  # services.ocis = {
  #   enable = true;
  #   address = "127.0.0.1";
  #   port = 8384;
  #   url = "http://0.0.0.0:8384";
  #   environment = {
  #     CS3_ALLOW_INSECURE = "true";
  #     GATEWAY_STORAGE_USERS_MOUNT_ID = "123";
  #     GRAPH_APPLICATION_ID = "1234";
  #     IDM_IDPSVC_PASSWORD = "password";
  #     IDM_REVASVC_PASSWORD = "password";
  #     IDM_SVC_PASSWORD = "password";
  #     IDP_ISS = "https://0.0.0.0:8385";
  #     IDP_TLS = "false";
  #     OCIS_INSECURE = "true";
  #     OCIS_INSECURE_BACKENDS = "true";
  #     OCIS_JWT_SECRET = "super_secret";
  #     OCIS_LDAP_BIND_PASSWORD = "password";
  #     OCIS_LOG_LEVEL = "error";
  #     OCIS_MACHINE_AUTH_API_KEY = "foo";
  #     OCIS_MOUNT_ID = "123";
  #     OCIS_SERVICE_ACCOUNT_ID = "foo";
  #     OCIS_SERVICE_ACCOUNT_SECRET = "foo";
  #     OCIS_STORAGE_USERS_MOUNT_ID = "123";
  #     OCIS_SYSTEM_USER_API_KEY = "foo";
  #     OCIS_SYSTEM_USER_ID = "123";
  #     OCIS_TRANSFER_SECRET = "foo";
  #     STORAGE_USERS_MOUNT_ID = "123";
  #     TLS_INSECURE = "true";
  #     TLS_SKIP_VERIFY_CLIENT_CERT = "true";
  #     WEBDAV_ALLOW_INSECURE = "true";
  #   };
  # };

  services.nginx = {
    enable = true;
    virtualHosts = {
      # "cloud.${domain}" = {
      #   forceSSL = true;
      #   enableACME = true;
      #   locations."/".proxyPass = "http://127.0.0.1:8384";
      # };

      "ff.${domain}" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  # services.postgresql = {
  #   enable = true;
  #   enableTCPIP = true;
  #   ensureDatabases = [ "firefly" ];
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #type database  DBuser  auth-method
  #     local all       all     trust
  #     # ipv4
  #     host  all      all     127.0.0.1/32   trust
  #     # ipv6
  #     host all       all     ::1/128        trust
  #   '';
  #   initialScript = pkgs.writeText "backend-initScript" ''
  #     CREATE ROLE firefly WITH LOGIN PASSWORD 'test' CREATEDB;
  #     CREATE DATABASE firefly;
  #     GRANT ALL PRIVILEGES ON DATABASE firefly TO firefly;
  #   '';
  # };

  services.firefly-iii = {
    inherit user;
    enable = true;
    enableNginx = true;
    virtualHost = "locahost";
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
      8384
      8385
      42069 # minecraft
      42068 # rcon minecraft
    ];
  };

  system.stateVersion = "24.11";
}
