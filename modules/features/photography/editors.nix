{
  flake.modules.nixos.photography = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ darktable ];
  };

  flake.modules.darwin.photography = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ brewCasks.darktable ];
  };
}
