{
  email,
  domain,
  ports,
}:
{
  enable = true;

  adminEmail = email;
  initialAdminPassword = "pass";

  ccnetSettings.General.SERVICE_URL = "https://cloud.${domain}";
  seafileSettings = {
    history.keep_days = "14";
    fileserver = {
      host = "127.0.0.1";
      port = ports.seafile;
    };
  };
  seahubExtraConf = ''
    DEBUG = True
    CSRF_TRUSTED_ORIGINS = ["https://cloud.${domain}"]
  '';
}
