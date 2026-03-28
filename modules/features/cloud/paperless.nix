{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      sops.secrets."paperless" = {
        owner = "paperless";
      };

      services.paperless = {
        enable = true;
        domain = "paperless.leoms.dev";
        dataDir = "/data/cloud/documents";
        port = config.registry.paperless.port;
        user = "paperless";
        passwordFile = config.sops.secrets."paperless".path;
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.paperless.port = 7999;
  };
}
