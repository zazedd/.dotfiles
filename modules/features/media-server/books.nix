let
  dbName = "rreading_glasses";
  dbUser = "rreading_glasses";
in
{
  flake.modules.nixos.mediaserver =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      port = config.registry.rreading-glasses.port;
      rreading-glasses = pkgs.callPackage ../../../pkgs/rreading-glasses { };
    in
    {
      sops.secrets."hardcover" = { };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ dbName ];
        ensureUsers = [
          {
            name = dbUser;
            ensureDBOwnership = true;
          }
        ];
        authentication = lib.mkAfter ''
          host ${dbName} ${dbUser} 127.0.0.1/32 trust
        '';
      };

      systemd.services.rreading-glasses = {
        description = "rreading-glasses";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "postgresql.service"
        ];
        requires = [ "postgresql.service" ];

        serviceConfig = {
          DynamicUser = true;
          LoadCredential = [ "hardcover-token:${config.sops.secrets.hardcover.path}" ];
          Restart = "on-failure";
          RestartSec = "5s";
        };

        script = ''
          export HARDCOVER_AUTH="$(cat "$CREDENTIALS_DIRECTORY/hardcover-token")"
          export POSTGRES_HOST="127.0.0.1"
          export POSTGRES_USER="${dbUser}"
          export POSTGRES_DATABASE="${dbName}"
          export POSTGRES_PORT="5432"
          export PORT="${toString port}"
          exec ${rreading-glasses}/bin/rghc serve
        '';
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.rreading-glasses = {
      port = 8585;
      aliases = [ "books" ];
    };
  };
}
