{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # general
  firefox
  zathura

  # programming
  alacritty
  bubblewrap
  mcrl2

  ## nix
  nixfmt-rfc-style
  nil
  nixd

  # wayland stuff
  wl-clipboard
  wtype

  ## screenshot
  grim
  slurp
  swappy

  ## gaming
  prismlauncher
  moonlight-qt

  ## others
  libsForQt5.qt5.qtwayland
  tidal-hifi
]
