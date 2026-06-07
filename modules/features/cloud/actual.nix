{ inputs, ... }:
{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          actual-server = (import inputs.nixpkgs-master { inherit (prev) system; }).actual-server;
        })
      ];

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
