{ config, ... }:
let
  user = config.flake.meta.users.zazed.name;
in
{
  flake.modules.homeManager.cloud-connection =
    { config, ... }:
    {
      sops.secrets."copyparty-${user}" = {
        sopsFile = ../../../secrets/server.yaml;
      };

      programs.rclone =
        let
          cfg = {
            user = user;
            type = "webdav";
            hard_delete = true;
            url = "https://cloud.leoms.dev/";
            vendor = "owncloud";
            pacer_min_sleep = "0.01ms";
          };
        in
        {
          enable = true;
          remotes = {
            "private" = {
              mounts."private" = {
                enable = true;
                mountPoint = "${config.home.homeDirectory}/cloud/private";
              };
              config = cfg;
              secrets = {
                pass = config.sops.secrets."copyparty-${user}".path;
              };
            };

            "public" = {
              mounts."public" = {
                enable = true;
                mountPoint = "${config.home.homeDirectory}/cloud/public";
              };
              config = cfg;
            };
          };
        };
    };
}
