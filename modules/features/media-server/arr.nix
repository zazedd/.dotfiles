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
      chaptarr = mediaDefaults;
      radarr = mediaDefaults;
      sonarr = mediaDefaults;
      bazarr = mediaDefaults;
      prowlarr.enable = true;
      flaresolverr.enable = true;
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
