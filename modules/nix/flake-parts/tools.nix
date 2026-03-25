{ inputs, ... }:
# setup flake-parts for dendritic pattern
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;
    };
}
