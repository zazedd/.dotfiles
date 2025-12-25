{ pkgs, old-betterdisplay-pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  nixos-shell
  gcalcli
  gmp
  dockutil
  dua

  # dev
  opam
  zoxide
  yazi
  wireguard-tools
  claude-code

  nodejs

  alacritty

  old-betterdisplay-pkgs.betterdisplay
]
