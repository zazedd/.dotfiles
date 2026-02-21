{
  config,
  ...
}:
{
  enable = true;
  domain = "paperless.leoms.dev";
  dataDir = "/data/cloud/documents";
  port = config.my.reverse-proxy.paperless.port;
  user = "paperless";
  passwordFile = config.sops.secrets."paperless".path;
}
