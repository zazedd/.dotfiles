{
  user,
  ports,
  config,
}:
{
  enable = true;
  settings = {
    i = "127.0.0.1";
    p = [
      ports.copyparty
      ports.copyparty_webdav
    ];
    no-reload = true;
    ignored-flag = false;
    ban-404 = "no";
    ban-403 = "no";
    ban-422 = "no";
    ban-url = "no";
    ban-pw = "no";
  };

  user = "copyparty";
  group = "cloud";

  accounts = {
    ${user}.passwordFile = config.sops.secrets."copyparty-${user}".path;
  };

  volumes = {
    "/private" = {
      path = "/data/cloud/private";
      access = {
        rwmd = [ user ];
      };
      flags = {
        fk = 4;
        scan = 60;
        e2d = true;
        d2t = false;
      };
    };

    "/public" = {
      path = "/data/cloud/public";
      access = {
        rw = "*";
      };
      flags = {
        fk = 4;
        scan = 60;
        e2d = true;
        d2t = true;
      };
    };
  };

  openFilesLimit = 8192;
}
