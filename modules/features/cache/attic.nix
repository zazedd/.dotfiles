_: {
  flake.modules.nixos.attic =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      port = config.registry.cache.port;
      host = "cache.${config.domain}";
      storagePath = "/data/cloud/attic";
    in
    {
      sops.secrets.atticd-env = { };
      environment.systemPackages = [ pkgs.attic-client ];

      users = {
        users.atticd = {
          isSystemUser = true;
          group = "atticd";
          extraGroups = [ "cloud" ];
          home = storagePath;
        };
        groups.atticd = { };
      };

      systemd.tmpfiles.rules = [
        "d ${storagePath} 0750 atticd atticd -"
      ];

      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.atticd-env.path;
        settings = {
          listen = "127.0.0.1:${toString port}";
          allowed-hosts = [ host ];
          api-endpoint = "https://${host}/";

          storage = {
            type = "local";
            path = storagePath;
          };

          garbage-collection = {
            interval = "12 hours";
            default-retention-period = "1 month";
          };
        };
      };

      # a static user allows Attic to write to storage on /data/cloud.
      systemd.services.atticd = {
        unitConfig.RequiresMountsFor = [ "/data/cloud" ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          PrivateUsers = lib.mkForce false;
          SupplementaryGroups = [ "cloud" ];
        };
      };

      registry.cache.port = 8081;
    };
}
