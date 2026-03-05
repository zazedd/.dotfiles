{ pkgs, config, ... }:
let
  tailscaleAuthScript = with pkgs; writeShellScript "tailscale-auth" ''
    sleep 2
    status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
    if [ $status = "Running" ]; then
      exit 0
    fi
    ${tailscale}/bin/tailscale up -authkey "$(cat ${config.sops.secrets.darwin.path})"
  '';
in
{
  services.tailscale.enable = true;

  sops.secrets.darwin = {
    sopsFile = ../../secrets/conn.yaml;
  };

  launchd.daemons.tailscale-autoconnect = {
    serviceConfig = {
      Label = "com.tailscale.autoconnect";
      ProgramArguments = [ "${tailscaleAuthScript}" ];
      RunAtLoad = true;
      StandardErrorPath = "/var/log/tailscale-autoconnect.err.log";
      StandardOutPath = "/var/log/tailscale-autoconnect.out.log";
    };
  };
}
