{
  config,
  ...
}:

{
  enable = true;
  group = "cloud";
  port = config.my.reverse-proxy.immich.port;
  mediaLocation = "/data/cloud/photos";
  host = "0.0.0.0";
  settings.server.externalDomain = "https://photos.leoms.dev";
  secretsFile = config.sops.secrets."immich-secrets".path;
}
