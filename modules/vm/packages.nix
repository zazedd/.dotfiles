{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  home-manager

  xorg.xrandr
  gnumake
  xdg-utils
  nmap
  dmenu
]
