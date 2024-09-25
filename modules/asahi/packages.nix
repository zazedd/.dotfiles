{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # general
  firefox

  # programming
  alacritty
  bubblewrap

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
]
