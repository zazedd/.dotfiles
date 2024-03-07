{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  nixos-shell

  gmp
  dockutil
  gdu
  zoxide
]
