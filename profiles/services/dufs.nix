{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.dufs;
  bindAddr =
    if !(builtins.isNull cfg.host) then
      cfg.host
    else if !(builtins.isNull cfg.socket) then
      cfg.socket
    else
      null;
  description = "dufs - A file server that supports static serving, uploading, searching, accessing control, webdav...";
in
{
  options.services.dufs = {
    enable = lib.mkEnableOption description;
    package = lib.mkPackageOption pkgs "dufs" { };

    servePath = lib.mkOption {
      type = types.path;
      default = "/var/lib/dufs";
    };

    host = lib.mkOption {
      type = types.nullOr types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = types.port;
      default = 5000;
    };

    socket = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    environment = lib.mkOption {
      type = types.attrsOf types.str;
      default = {
        DUFS_SERVE_PATH = cfg.servePath;
        DUFS_BIND = bindAddr;
        DUFS_PORT = toString cfg.port;
        DUFS_COMPRESS = cfg.compressionLevel;

        DUFS_ALLOW_ALL = "false";
        DUFS_ALLOW_UPLOAD = "true";
        DUFS_ALLOW_DELETE = "true";
        DUFS_ALLOW_SEARCH = "true";
        DUFS_ALLOW_SYMLINK = "false";
        DUFS_ALLOW_ARCHIVE = "true";
      };
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    openFirewall = lib.mkOption {
      type = types.bool;
      default = false;
    };

    compressionLevel = lib.mkOption {
      type = types.enum [
        "none"
        "low"
        "medium"
        "high"
      ];
      default = "low";
    };

    extraConfigFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    user = lib.mkOption {
      type = types.str;
      default = "dufs";
    };

    group = lib.mkOption {
      type = types.str;
      default = "dufs";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(builtins.isNull bindAddr);
        message = "DUFS must listen to at least one of http port or unix socket.";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.dufs = {
      inherit description;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = cfg.environment;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = lib.concatStringsSep " " (
          [
            "${lib.getExe cfg.package}"
            "${cfg.servePath}"
          ]
          ++ (lib.optionals (!builtins.isNull cfg.extraConfigFile) [
            "--config"
            "${cfg.extraConfigFile}"
          ])
        );
        # https://github.com/sigoden/dufs/issues/506
        ExecStartPost = lib.optionals (!builtins.isNull cfg.socket) [
          "${lib.getExe' pkgs.coreutils "sleep"} 1"
          "${lib.getExe' pkgs.coreutils "chmod"} 0777 ${cfg.socket}"
        ];
        PrivateTmp = true;
        StateDirectory = "dufs";
        RuntimeDirectory = "dufs";
        RuntimeDirectoryMode = "0777";
        WorkingDirectory = cfg.servePath;
      };
    };

    users = {
      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
      groups.${cfg.group} = { };
    };
  };
}
