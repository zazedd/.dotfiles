let
  mediaDefaults = {
    enable = true;
    user = "media";
    group = "media";
  };
in
{
  flake.modules.nixos.mediaserver = {
    services = {
      radarr = mediaDefaults;
      sonarr = mediaDefaults;
      bazarr = mediaDefaults;
      prowlarr.enable = true;
      flaresolverr.enable = true;
    };
  };

  flake.modules.nixos.reverse-proxy = {
    registry = {
      radarr.port = 7878;
      sonarr.port = 8989;
      bazarr.port = 6767;
      prowlarr.port = 9696;
    };
  };
}
