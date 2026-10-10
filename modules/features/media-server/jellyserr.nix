{
  flake.modules.nixos.mediaserver = {
    services.seerr.enable = true;
    email-on-failure.seerr = true;
  };

  flake.modules.nixos.reverse-proxy = {
    registry.jellyseerr = {
      port = 5055;
      aliases = [ "request" ];
    };
  };
}
