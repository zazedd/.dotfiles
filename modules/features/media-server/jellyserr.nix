{
  flake.modules.nixos.mediaserver = {
    services.seerr.enable = true;
    systemd.services.seerr.environment.HOST = "127.0.0.1";
    email-on-failure.seerr = true;
  };

  flake.modules.nixos.reverse-proxy = {
    registry.jellyseerr = {
      port = 5055;
      aliases = [ "request" ];
    };
  };
}
