{
  ports,
  config,
}:
{
  enable = true;
  dataDir = "/data/cloud/private/documents";
  port = ports.paperless;
  user = "paperless";
  passwordFile = config.sops.secrets."paperless".path;
}
