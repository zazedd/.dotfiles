{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  nixos-shell

  (fenix.complete.withComponents [
   "cargo"
   "clippy"
   "rust-src"
   "rustc"
   "rustfmt"
   "rust-analyzer"
  ])

  colima
  arion
  docker-client
  qmk
  opam
  yazi
  gcalcli
  gmp
  dockutil
  gdu
  zoxide
]
