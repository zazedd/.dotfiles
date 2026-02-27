{
  config,
  domain,
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
    extraGroups = [
      "render"
      "video"
    ];
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
      port = config.my.reverse-proxy.deluge.port;
    };
  };
  services.sabnzbd = mediaDefaults // { settings.misc.special.host_whitelist = domain; };

  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = mediaDefaults;
}
