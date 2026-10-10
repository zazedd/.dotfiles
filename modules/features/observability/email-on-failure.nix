{ config, ... }:
let
  recipient = config.flake.meta.users.zazed.email;
  sender = "leopardextremex@gmail.com";
in
{
  flake.modules.nixos.email-on-failure =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.email-on-failure = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        example = {
          actual = true;
          nginx = true;
        };
        description = ''
          Systemd services whose failures should trigger an email notification.
          Attribute names are systemd service names without the .service suffix.
        '';
      };

      config = {
        systemd.services =
          lib.mapAttrs (_name: _enabled: {
            onFailure = [ "email-on-failure@%n.service" ];
          }) (lib.filterAttrs (_name: enabled: enabled) config.email-on-failure)
          // {
            "email-on-failure@" = {
              description = "Email notification for failed unit %i";
              serviceConfig.Type = "oneshot";
              path = [ pkgs.systemd ];
              scriptArgs = "%i";
              script = ''
                unit="$1"
                {
                  printf 'To: %s\n' ${recipient}
                  printf 'From: %s\n' ${sender}
                  printf 'Subject: [${config.networking.hostName}] systemd failure: %s\n' "$unit"
                  printf '\n'
                  systemctl --no-pager --full status "$unit" || true
                  printf '\nRecent journal output:\n'
                  journalctl --no-pager -u "$unit" -n 200 || true
                } | /run/wrappers/bin/sendmail -t
              '';
            };
          };
      };
    };
}
