{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      services.actual = {
        enable = true;
        settings = {
          hostname = "0.0.0.0";
          port = config.registry.actual.port;
        };
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.actual.port = 8282;
  };
}
