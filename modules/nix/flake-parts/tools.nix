{ inputs, ... }:
# setup flake-parts for dendritic pattern
{
  inputs = [ inputs.flake-file.flakeModules.default ];
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
