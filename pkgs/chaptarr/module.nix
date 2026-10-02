{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chaptarr;
  helpers = import ./settings-options.nix { inherit lib pkgs; };
in
{
  options.services.chaptarr = {
    enable = lib.mkEnableOption "Chaptarr, a book collection manager for audiobooks and eBooks";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Chaptarr package to use.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/chaptarr/.config/Chaptarr";
      description = "Directory where Chaptarr stores its configuration and database.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the Chaptarr web interface port in the firewall.";
    };

    inherit (helpers) settings environmentFiles;

    user = lib.mkOption {
      type = lib.types.str;
      default = "chaptarr";
      description = "User account under which Chaptarr runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "chaptarr";
      description = "Group under which Chaptarr runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-chaptarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.chaptarr = {
      description = "Chaptarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = helpers.toEnvironment cfg.settings;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${lib.getExe cfg.package} -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        UMask = "0022";
        ProtectHostname = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@debug"
          "~@mount"
          "@chown"
        ];
      };

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.server.port ];

    users.users.chaptarr = lib.mkIf (cfg.user == "chaptarr") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };

    users.groups.chaptarr = lib.mkIf (cfg.group == "chaptarr") { };
  };
}
