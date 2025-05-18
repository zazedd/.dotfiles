{ pkgs }:
{
  services.jellyfin.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;

  services.prowlarr.enable = true;
  services.deluge = {
    enable = true;
    openFirewall = true;
    web = {
      enable = true;
      openFirewall = true;
      port = 5000;
    };
  };

  services.jellyseerr.enable = true;
  services.bazarr.enable = true;
}
