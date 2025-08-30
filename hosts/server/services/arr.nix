{
  ports,
  my_pkgs,
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

  services.jellyfin = mediaDefaults;
  services.sonarr = mediaDefaults;
  services.radarr = mediaDefaults;
  services.lidarr = mediaDefaults;

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

  services.jellyseerr = {
    enable = true;
    package = my_pkgs.jellyseerr;
  };
  services.bazarr = mediaDefaults;
}
