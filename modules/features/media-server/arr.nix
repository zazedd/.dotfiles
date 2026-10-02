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
    imports = [ inputs.self.modules.nixos.chaptarr ];

    services = {
      chaptarr = mediaDefaults;
      radarr = mediaDefaults;
      sonarr = mediaDefaults;
      readarr = mediaDefaults;
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
      readarr = {
        port = 8787;
        aliases = [ "books" ];
      };
      bazarr.port = 6767;
      prowlarr.port = 9696;
    };
  };
}
