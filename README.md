# Nix Config for macOS and NixOS

## Overview
This repository contains my configuration for my systems, specifically Nix on macOS, a NixOS VM, and my Gaming rig and Server in the future.

## Table of Contents
- [Overview](#overview)
- [Layout](#layout)
- [Features](#features)
- [Building and Deploying](#building-and-deploying)
  - [For macOS (Feb 2024)](#for-macos-february-2024)
    - [Build check](#1-build-check)
    - [Make changes](#2-make-changes)
  - [For all platforms](#for-all-platforms)
    - [Deploying](#deploying)
    - [Update Dependencies](#update-dependencies)
- [Compatibility and Testing](#compatibility-and-testing)

## Layout
```
.
├── apps         # Nix commands used to bootstrap and build configuration
├── configs      # Normal .config/ configurations I call inside of Nix
├── hosts        # Host-specific configuration
├── modules      # macOS and nix-darwin, NixOS, and shared configuration
├── nix-secrets  # Secrets handling with agenix
└── overlays     # Drop an overlay file in this dir, and it runs. So far, mainly patches.
```

## Features
- **Nix Flakes**: 100% flake driven, no `configuration.nix`, [no Nix channels](#why-nix-flakes)─ just `flake.nix`
- **Same Environment Everywhere**: Easily share config across Linux and macOS (both Nix and Home Manager)
- **macOS Setup**: Fully declarative macOS w/ UI, dock and macOS App Store apps, homebrew taps, casks, and brews
- **Simple Bootstrap**: Simple Nix commands to start from zero, both x86 and macOS platforms
- **Managed Homebrew**: Zero maintenance homebrew environment with `nix-darwin` and `nix-homebrew`
- **Disk Management**: Declarative disk management with `disko`, no more disk utils
- **Secrets Management**: Declarative secrets with `agenix` for SSH, PGP, syncthing, and other tools
- **Built In Home Manager**: `home-manager` module for seamless configuration (no extra clunky CLI steps)
- **Declarative Sync**: No-fuss Syncthing: managed keys, certs, and configuration across all platforms
- **Simplicity and Readability**: Optimized for simplicity and readability in all cases, not small files everywhere
- **Backed by Continuous Integration**: Flake auto updates weekly if changes don't break starter build

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
> [!CAUTION]
> `~/.zshrc` will be replaced with the [`zsh` configuration](https://github.com/dustinlyons/nixos-config/blob/main/templates/starter/modules/shared/home-manager.nix#L8) from this repository. Make edits here first if you'd like.

## For all platforms

### Deploying
```sh
nix run .#build-switch
```
### Update dependencies
```sh
nix flake update
```
## Compatibility and Testing
I have personally tested this configuration on an:
- M1 Apple Silicon Mac
- Bare metal x86_64 PC
- aarch64 NixOS VM inside QEMU on macOS
