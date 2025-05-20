{
  pkgs,
  ...
}:

let
  mediaDefaults = {
    enable = true;
    user = "media";
    group = "media";
  };
  ports = import ./ports.nix;
in
{
  users.users.media = {
    isSystemUser = true;
    description = "media user for arr services";
    group = "media";
  };

  users.groups.media = { };

  services.jellyfin = mediaDefaults;
  services.sonarr = mediaDefaults;
  services.radarr = mediaDefaults;

  services.prowlarr.enable = true;

  services.deluge = {
    enable = true;
    group = "media";
    openFirewall = true;
    web = {
      enable = true;
      openFirewall = true;
      port = ports.deluge;
    };
  };
  services.sabnzbd = mediaDefaults;

  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = mediaDefaults;

  services.glance = {
    enable = true;
    settings = {
      server = {
        port = ports.homepage;
      };
      pages = [
        {
          name = "Home";
          head-widgets = [
            {
              type = "markets";
              hide-header = true;
              markets = [
                {
                  symbol = "VWCE";
                  name = "VWCE";
                }

                {
                  symbol = "BTC-USD";
                  name = "Bitcoin";
                }
              ];
            }
          ];
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                }
                {
                  type = "weather";
                  location = "Porto, Portugal";
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
