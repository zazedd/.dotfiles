{
  config,
  lib,
  ...
}:

let
  cfg = config.services.bindery;
in
{
  options.services.bindery = {
    enable = lib.mkEnableOption "Bindery, an automated ebook and audiobook manager";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Bindery package to use.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/bindery";
      description = "Directory containing Bindery's database, backups, and image cache.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "Port on which Bindery listens.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the Bindery web interface port in the firewall.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        BINDERY_LIBRARY_DIR = "/mnt/media/books";
        BINDERY_DOWNLOAD_DIR = "/mnt/media/downloads";
        BINDERY_LOG_LEVEL = "info";
      };
      description = ''
        Additional environment variables for Bindery. See the upstream deployment
        documentation for the supported BINDERY_* variables. Values here can
        override the defaults derived from `dataDir` and `port`.
      '';
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Files containing environment variables or secrets for Bindery.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "bindery";
      description = "User account under which Bindery runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "bindery";
      description = "Group under which Bindery runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-bindery".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.bindery = {
      description = "Bindery ebook and audiobook manager";
      documentation = [ "https://github.com/vavallee/bindery" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        BINDERY_DATA_DIR = cfg.dataDir;
        BINDERY_DB_PATH = "${cfg.dataDir}/bindery.db";
        BINDERY_PORT = toString cfg.port;
      }
      // cfg.environment;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStopSec = 30;

        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0027";
      };

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    users.users.bindery = lib.mkIf (cfg.user == "bindery") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };

    users.groups.bindery = lib.mkIf (cfg.group == "bindery") { };
  };
}
