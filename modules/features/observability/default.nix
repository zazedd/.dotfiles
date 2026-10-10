_:
let
  sender = "leopardextremex@gmail.com";
in
{
  flake.modules.nixos.observability =
    {
      config,
      pkgs,
      ...
    }:
    let
      smtpPassword = pkgs.writeShellScript "smtp-password" ''
        password="$(${pkgs.coreutils}/bin/tr -d '[:space:]' < ${config.sops.secrets.smtp-password.path})"
        ${pkgs.coreutils}/bin/printf '%s\n' "$password"
      '';
    in
    {
      sops.secrets = {
        smtp-password = { };
        beszel-pk = {
          owner = "beszel-agent";
          group = "beszel-agent";
        };
        beszel-token = {
          owner = "beszel-agent";
          group = "beszel-agent";
        };
      };

      programs.msmtp = {
        enable = true;
        defaults = {
          auth = true;
          tls = true;
          tls_starttls = true;
          logfile = "syslog";
        };
        accounts.default = {
          host = "smtp.gmail.com";
          port = 587;
          from = sender;
          user = sender;
          passwordeval = smtpPassword;
        };
      };

      services.beszel = {
        hub = {
          enable = true;
          port = config.registry.beszel.port;
          environment.APP_URL = "https://beszel.${config.domain}";
        };
        agent = {
          enable = true;
          environment = {
            HUB_URL = "http://127.0.0.1:${toString config.registry.beszel.port}";
            KEY_FILE = config.sops.secrets.beszel-pk.path;
            TOKEN_FILE = config.sops.secrets.beszel-token.path;
          };
        };
      };

      systemd.services.beszel-agent = {
        requires = [ "beszel-hub.service" ];
        after = [ "beszel-hub.service" ];
      };

      services.smartd.enable = true;

      email-on-failure = {
        beszel-agent = true;
        beszel-hub = true;
        smartd = true;
      };

      registry.beszel.port = 8090;
    };
}
