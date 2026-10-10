{ inputs, ... }:
{
  flake.modules.nixos.server =
    { config, ... }:
    let
      sunshinePort = config.services.sunshine.settings.port;
    in
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
          interfaces.tailscale0 = {
            allowedTCPPorts = [
              80
              443
              (sunshinePort - 5)
              sunshinePort
              (sunshinePort + 1)
              (sunshinePort + 21)
            ];
            allowedUDPPorts = [
              (sunshinePort + 9)
              (sunshinePort + 10)
              (sunshinePort + 11)
              (sunshinePort + 13)
              (sunshinePort + 21)
            ];
          };
        };
      };

      # Moonlight connects by hostname, so LAN-wide mDNS exposure is unnecessary.
      services.avahi.openFirewall = false;
    };
}
