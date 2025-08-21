{
  config,
  ports,
  ...
}:

{
  enable = true;
  group = "cloud";
  port = ports.immich;
  mediaLocation = "/data/cloud/photos";
  host = "0.0.0.0";
  settings.server.externalDomain = "https://photos.leoms.dev";
  secretsFile = config.sops.secrets."immich-secrets".path;
}
