{
  config,
  email,
  domain,
}:
{
  enable = true;
  enableNginx = true;
  virtualHost = "ff.${domain}";
  settings = {
    APP_ENV = "production";
    APP_KEY_FILE = config.sops.secrets."firefly-api".path;
    SITE_OWNER = email;
  };
}
