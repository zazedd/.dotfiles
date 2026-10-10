{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      services.actual = {
        enable = true;
        settings = {
          hostname = "127.0.0.1";
          port = config.registry.actual.port;
        };
      };

      email-on-failure.actual = true;
    };

  flake.modules.nixos.reverse-proxy = {
    registry.actual.port = 8282;
  };
}
