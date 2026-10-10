{ inputs, ... }:
let
  mediaDefaults = {
    enable = true;
    user = "media";
    group = "media";
  };
in
{
  flake.modules.nixos.mediaserver = {
    imports = [
      inputs.self.modules.nixos.bindery
      inputs.self.modules.nixos.chaptarr
    ];

    services = {
      bindery = mediaDefaults // {
        environment = {
          BINDERY_LIBRARY_DIR = "/data/media/books";
          BINDERY_DOWNLOAD_DIR = "/data/media/downloads";
          # Prowlarr returns localhost NZB URLs when co-located on this host.
          BINDERY_DOWNLOAD_ALLOW_LOOPBACK = "1";
        };
      };
      chaptarr = mediaDefaults // {
        settings.server.bindAddress = "127.0.0.1";
      };
      radarr = mediaDefaults // {
        settings.server.bindAddress = "127.0.0.1";
      };
      sonarr = mediaDefaults // {
        settings.server.bindAddress = "127.0.0.1";
      };
      bazarr = mediaDefaults;
      prowlarr = {
        enable = true;
        settings.server.bindAddress = "127.0.0.1";
      };
      flaresolverr.enable = true;
    };

    systemd.services =
      builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value.unitConfig.RequiresMountsFor = [ "/data/media" ];
          })
          [
            "bazarr"
            "bindery"
            "chaptarr"
            "radarr"
            "sonarr"
          ]
      )
      // {
        flaresolverr.environment.HOST = "127.0.0.1";
      };

    email-on-failure = {
      bazarr = true;
      bindery = true;
      chaptarr = true;
      flaresolverr = true;
      prowlarr = true;
      radarr = true;
      sonarr = true;
    };
  };

  flake.modules.nixos.reverse-proxy = {
    registry = {
      chaptarr.port = 8789;
      radarr.port = 7878;
      sonarr.port = 8989;
      bindery = {
        port = 8787;
        aliases = [ "books" ];
      };
      bazarr.port = 6767;
      prowlarr.port = 9696;
    };
  };
}
