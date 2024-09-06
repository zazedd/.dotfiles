{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  firefox
  powertop

  # programming
  opam
  alacritty
  gcc
  gnumake
  pkg-config
  bubblewrap
]
