{
  config,
  ports,
  ...
}:
{
  enable = true;
  domain = "paperless.leoms.dev";
  dataDir = "/data/cloud/documents";
  port = ports.paperless;
  user = "paperless";
  passwordFile = config.sops.secrets."paperless".path;
}
