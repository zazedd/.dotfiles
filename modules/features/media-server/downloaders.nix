{
  flake.modules.nixos.mediaserver =
    { config, ... }:
    {
      services.sabnzbd = {
        enable = true;
        user = "media";
        group = "media";
        settings.misc.special.host_whitelist = config.domain;
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.sabnzbd.port = 8080;
  };
}
