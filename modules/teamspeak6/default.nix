{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.teamspeak6;
  user = "teamspeak6";
  group = "teamspeak6";
in
{
  options = {
    services.teamspeak6 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run the Teamspeak 6 voice communication server daemon.
        '';
      };

      package = mkPackageOption pkgs "teamspeak6-server" {};

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/teamspeak6-server";
        description = ''
          Directory to store TS6 database and other state/data files.
        '';
      };

      logPath = mkOption {
        type = types.path;
        default = "/var/log/teamspeak6-server/";
        description = ''
          Directory to store log files in.
        '';
      };

      voiceIP = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "[::]";
        description = ''
          IP on which the server instance will listen for incoming voice connections. Defaults to any IP.
        '';
      };

      defaultVoicePort = mkOption {
        type = types.port;
        default = 9987;
        description = ''
          Default UDP port for clients to connect to virtual servers - used for first virtual server, subsequent ones will open on incrementing port numbers by default.
        '';
      };

      fileTransferIP = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "[::]";
        description = ''
          IP on which the server instance will listen for incoming file transfer connections. Defaults to any IP.
        '';
      };

      fileTransferPort = mkOption {
        type = types.port;
        default = 30033;
        description = ''
          TCP port opened for file transfers.
        '';
      };

      queryIP = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "0.0.0.0";
        description = ''
          IP on which the server instance will listen for incoming ServerQuery connections. Defaults to any IP.
        '';
      };

      queryPort = mkOption {
        type = types.port;
        default = 10011;
        description = ''
          TCP port opened for ServerQuery connections using the raw telnet protocol.
        '';
      };

      querySshPort = mkOption {
        type = types.port;
        default = 10022;
        description = ''
          TCP port opened for ServerQuery connections using the SSH protocol.
        '';
      };

      queryHttpPort = mkOption {
        type = types.port;
        default = 10080;
        description = ''
          TCP port opened for ServerQuery connections using the HTTP protocol.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the TeamSpeak3 server.";
      };

      openFirewallServerQuery = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the TeamSpeak3 serverquery (administration) system. Requires openFirewall.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users."${user}" = {
      description = "Teamspeak6 voice communication server daemon";
      group = group;
      # uid = config.ids.uids.teamspeak;
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    users.groups."${group}" = {
      # gid = config.ids.gids.teamspeak;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.logPath}' - ${user} ${group} - -"
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.fileTransferPort ]
        ++ optionals cfg.openFirewallServerQuery [
          cfg.queryPort
          cfg.querySshPort
          cfg.queryHttpPort
        ];

      # subsequent vServers will use the incremented voice port, let's just open the next 10
      allowedUDPPortRanges = [
        {
          from = cfg.defaultVoicePort;
          to = cfg.defaultVoicePort + 10;
        }
      ];
    };

    systemd.services.teamspeak6-server = {
      description = "Teamspeak6 voice communication server daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/tsserver \
            --db-sql-path=${cfg.package}/share/teamspeak6-server/sql/ \
            --log-path=${cfg.logPath} \
            --accept-license=1 \
            --default-voice-port=${toString cfg.defaultVoicePort} \
            --filetransfer-port=${toString cfg.fileTransferPort} \
            --query-ssh-port=${toString cfg.querySshPort} \
            --query-http-port=${toString cfg.queryHttpPort} \
            ${optionalString (cfg.voiceIP != null) "--voice-ip=${cfg.voiceIP}"} \
            ${optionalString (cfg.fileTransferIP != null) "--filetransfer-ip=${cfg.fileTransferIP}"} \
            ${optionalString (cfg.queryIP != null) "--query-ssh-ip=${cfg.queryIP}"} \
            ${optionalString (cfg.queryIP != null) "--query-http-ip=${cfg.queryIP}"} \
        '';
        WorkingDirectory = cfg.dataDir;
        User = user;
        Group = group;
        Restart = "on-failure";
      };
    };
  };
}
