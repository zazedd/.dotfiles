{
  flake.modules.nixos.mediaserver = {
    services.seerr.enable = true;
  };

  flake.modules.nixos.reverse-proxy = {
    registry.jellyseerr = {
      port = 5055;
      aliases = [ "request" ];
    };
  };
}
