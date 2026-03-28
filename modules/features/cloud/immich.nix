let
  alias = "photos";
in
{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      sops.secrets."immich-secrets" = { };

      services.immich = {
        enable = true;
        group = "cloud";
        port = config.registry.immich.port;
        mediaLocation = "/data/cloud/photos";
        host = "0.0.0.0";
        settings.server.externalDomain = "https://${alias}.${config.domain}";
        secretsFile = config.sops.secrets."immich-secrets".path;
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.immich = {
      port = 2283;
      aliases = [ alias ];
    };
  };
}
