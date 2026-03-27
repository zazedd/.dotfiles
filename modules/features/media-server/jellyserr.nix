{
  flake.modules.nixos.jellyseerr = {
    services.jellyseerr.enable = true;
  };

  flake.modules.nixos.reverse-proxy = {
    registry.jellyseerr = {
      port = 5055;
      aliases = [ "request" ];
    };
  };
}
