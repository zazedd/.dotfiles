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
in
{
  users.users.media = {
    isSystemUser = true;
    description = "media user for arr services";
    group = "media";
  };

  users.groups.media = { };

  services.jellyfin = {
    enable = true;
    group = "media";
  };
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
      port = 5000;
    };
  };
  services.sabnzbd = mediaDefaults;

  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = mediaDefaults;
}
