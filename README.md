# .dotfiles

## Overview
This repository contains the configurations for my systems.  
Currently, an x86_64-linux machine, aarch64-linux asahi machine, nix-darwin macbook, and a homelab server.

## Layout
```
.
├── apps         # nix commands used to bootstrap and build
├── configs      # regular .config/ configurations
├── hosts        # host-specific configurations
├── modules      # custom modules
├── overlays     # patch overlays
├── pkgs         # custom packages
├── profiles     # shared and individual (home-manager) configurations
└── secrets      # secrets handling with sops-nix
```

# Building and Deploying
## For macOS
```sh
nix run .#build-switch
```

## Other Systems
```sh
nixosConfigurations
  ├───asahi (aarch64-linux): NixOS configuration
  ├───lenovo (x86_64-linux): NixOS configuration
  └───server (x86_64-linux): NixOS configuration
```
