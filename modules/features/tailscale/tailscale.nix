let
  tailscaleAuthScript =
    machine: config: pkgs:
    with pkgs;
    writeShellScript "tailscale-auth" ''
      sleep 2
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        exit 0
      fi
      ${tailscale}/bin/tailscale up --auth-key "$(cat ${config.sops.secrets.${machine}.path})"
    '';
in
{
  flake.modules.nixos.tailscale =
    { config, ... }:
    let
      authKey = config.sops.secrets.${config.networking.hostName};
    in
    {
      services.tailscale = {
        enable = true;
        authKeyFile = authKey.path;
      };

      sops.secrets.${config.networking.hostName} = {
        sopsFile = ../../../secrets/conn.yaml;
      };
    };

  flake.modules.darwin.tailscale =
    { pkgs, config, ... }:
    {
      services.tailscale.enable = true;

      sops.secrets.darwin = {
        sopsFile = ../../../secrets/conn.yaml;
      };

      launchd.daemons.tailscale-autoconnect = {
        serviceConfig = {
          Label = "com.tailscale.autoconnect";
          ProgramArguments = [ "${(tailscaleAuthScript "darwin" config pkgs)}" ];
          RunAtLoad = true;
          StandardErrorPath = "/var/log/tailscale-autoconnect.err.log";
          StandardOutPath = "/var/log/tailscale-autoconnect.out.log";
        };
      };
    };
}
