{
  flake.modules.nixos.work =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ wireguard-tools ];
    };
  flake.modules.darwin.work =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ wireguard-tools ];
    };
}
