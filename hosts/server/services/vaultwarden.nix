{
  ports,
  config,
  domain,
}:
{
  enable = true;
  backupDir = "/backup/bitwarden";
  config = {
    DOMAIN = "https://bitwarden.${domain}";
    SIGNUPS_ALLOWED = true;
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = ports.bitwarden;
  };
  environmentFile = config.sops.secrets."vaultwarden-env".path;
}
