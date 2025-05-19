{
  pkgs,
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
    # TODO: not a very good idea to have the api keys exposed in this ini file. might write a small module to change the host whitelists
    configFile = pkgs.writeText "sabnzbd.ini" (builtins.readFile ../../configs/sabnzbd/sabnzbd.ini);
  };

  systemd.services.sabnzbd = {
    serviceConfig = {
      WorkingDirectory = "/var/lib/sabnzbd";
    };
  };

  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = {
    enable = true;
    group = "media";
  };
}
