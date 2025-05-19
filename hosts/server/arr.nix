{
  ...
}:

{
  users.groups.media = { };

  services.jellyfin = {
    enable = true;
    group = "media";
  };
  services.sonarr = {
    enable = true;
    group = "media";
  };
  services.radarr = {
    enable = true;
    group = "media";
  };

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
  services.sabnzbd = {
    enable = true;
    group = "media";
  };
  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = {
    enable = true;
    group = "media";
  };
}
