# NixOS Config for most of my systems (Asahi Linux, macOS, NixOS server)

## Overview
This repository contains the configurations for my systems. Currently, an Asahi Linux + macOS nix-darwin M1 macbook, and a homelab server.

## Table of Contents
- [Overview](#overview)
- [Layout](#layout)
- [Building and Deploying](#building-and-deploying)
  - [For macOS (Feb 2024)](#for-macos-february-2024)
    - [Build check](#1-build-check)
    - [Make changes](#2-make-changes)
  - [Other systems](#other-systems)

## Layout
```
.
├── apps         # Nix commands used to bootstrap and build configuration
├── configs      # Normal .config/ configurations I call inside of Nix (set as XDG_CONFIG_DIR)
├── hosts        # Host-specific configuration
├── modules      # NixOS, nix-darwin, and shared configuration
├── secrets      # Secrets handling with sops-nix
└── overlays     # Drop an overlay file in this dir, and it runs. So far, mainly patches.
```

# Building and Deploying
## For macOS (March 2024)
This configuration supports both Intel and Apple Silicon Macs.

### 1. Build check
Ensure the build works before deploying the configuration, run:
```sh
nix run .#build
```
> [!NOTE]
> If you're using a git repository, only files in the working tree will be copied to the [Nix Store](https://zero-to-nix.com/concepts/nix-store).
>
> You must run `git add .` first.

> [!WARNING]
> You may encounter `error: Unexpected files in /etc, aborting activation` if `nix-darwin` detects it will overwrite
> an existing `/etc/` file. The error will list the files like this:
> 
> ```
> The following files have unrecognized content and would be overwritten:
> 
>   /etc/nix/nix.conf
>   /etc/bashrc
> 
> Please check there is nothing critical in these files, rename them by adding .before-nix-darwin to the end, and then try again.
> ```
> Backup and move the files out of the way and/or edit your Nix configuration before continuing.

### 2. Make changes
Alter your system with this command:
```sh
nix run .#build-switch
```

## Other Systems
They work as normal NixOS systems, so for instance, for my Asahi system:
```sh
nixos-rebuild switch --flake .#asahi
```
