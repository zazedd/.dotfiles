{
  config,
  ports,
  ...
}:
{
  enable = true;
  group = "cloud";
  port = ports.dufs;
  environmentFile = config.sops.secrets."dufs-env".path;
  servePath = "/data/cloud/files";
}
