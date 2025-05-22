{ pkgs }:

with pkgs;
[

  # secrets
  sops

  # General packages for development and system management
  zoxide
  starship
  bash-completion
  bat
  btop
  coreutils
  killall
  fastfetch
  wget
  zip
  gcc
  gnumake
  pkg-config
  gnused
  gnugrep
  gawk
  dua

  # Encryption and security tools
  openssl
  gnupg

  # Media-related packages
  ffmpeg
  fd

  # Text and terminal utilities
  htop
  eza
  jq
  ripgrep
  fzf
  tree
  unrar
  unzip
]
