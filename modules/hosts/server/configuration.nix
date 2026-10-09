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

        remote-desktop
        gaming
        work
      ];

      sops.defaultSopsFile = ../../../secrets/server.yaml;
      domain = "leoms.dev";

      nix.settings = {
        substituters = [ "https://cache.leoms.dev/dotfiles" ];
        trusted-public-keys = [
          "dotfiles:L8eOKFwsyzXtQShyNzr9HpLA2T2owJFE9XbzMyb3Rn0="
        ];
      };

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
