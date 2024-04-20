{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  home-manager

  cron
  alacritty
  # xorg.xrandr
  gnumake
  xdg-utils
  nmap
  # dmenu
]
