{
  flake.modules.nixos.lenovo = {
    networking = {
      hostName = "shitmachine";

      wireless.iwd = {
        enable = true;
        settings.General.EnableNetworkConfiguration = true;
      };

      wireguard.enable = true;

      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";

      nameservers = [ "9.9.9.9" ];
    };
  };
}
