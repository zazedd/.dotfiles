{
  flake.modules.darwin.work =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ wireguard-tools ];
    };
}
