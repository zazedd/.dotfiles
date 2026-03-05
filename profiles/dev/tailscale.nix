{ pkgs, config, machine, ... }:
let
  tailscaleAuthScript = with pkgs; writeShellScript "tailscale-auth" ''
    sleep 2
    status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
    if [ $status = "Running" ]; then
      exit 0
    fi
    ${tailscale}/bin/tailscale up -authkey "$(cat ${config.sops.secrets.${machine}.path})"
  '';
in
{
  services.tailscale.enable = true;

  sops.secrets.${machine} = {
    sopsFile = ../../secrets/conn.yaml;
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = builtins.readFile tailscaleAuthScript;
  };
}
