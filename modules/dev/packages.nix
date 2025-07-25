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
  tigervnc
  deluge
  mpv
  usbutils
  pinentry
  wireguard-tools

  # programming
  alacritty
  bubblewrap
  libev
  libevent

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

  ## entertainment
  jellyfin-media-player

  ## others
  libsForQt5.qt5.qtwayland
]
