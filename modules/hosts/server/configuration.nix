{ inputs, ... }:
{
  flake.modules.nixos.server =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-cli
        domain
        reverse-proxy
        attic
        cloud
        mediaserver
        llm
        observability

        remote-desktop
        gaming
        work
      ];

      sops.defaultSopsFile = ../../../secrets/server.yaml;
      domain = "leoms.dev";

      networking = {
        hostName = "xinho";
        firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [
            config.services.tailscale.port
          ];
        };
      };
    };
}
