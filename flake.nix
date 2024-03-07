{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; 
    homebrew-cask-fonts = {
      url = "github:homebrew/homebrew-cask-fonts";
      flake = false;
    }; 
    homebrew-services= {
      url = "github:homebrew/homebrew-services";
      flake = false;
    }; 
    koek = {
      url = "github:koekeishiya/homebrew-formulae";
      flake = false;
    }; 
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/zazedd/nix-secrets.git";
      flake = false;
    };
  };
  outputs = { self, secrets, darwin, nix-homebrew, neovim-nightly-overlay, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-services, homebrew-cask-fonts, koek, home-manager, nixpkgs, disko, agenix } @inputs:
    let
      user = "zazed";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git age age-plugin-yubikey ];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "homebrew/homebrew-services" = homebrew-services;
                  "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
                  "koekeishiya/formulae" = koek;
                };
                mutableTaps = true;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );

      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [
            # disko.nixosModules.disko
            home-manager.nixosModules.home-manager {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./modules/vm/home-manager.nix;
              };
            }
            ./hosts/vm
          ];
        };

        simple-vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;
          modules = [
            {
              virtualisation.vmVariant.virtualisation.graphics = false;
              virtualisation.vmVariant.virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            }
            # disko.nixosModules.disko
            # home-manager.nixosModules.home-manager {
            #   home-manager = {
            #     useGlobalPkgs = true;
            #     useUserPackages = true;
            #     users.${user} = import ./modules/vm/home-manager.nix;
            #   };
            # }
            # ./hosts/vm
            ./hosts/simple-vm
          ];
        };
      };

    packages.aarch64-darwin.simple-vm = self.nixosConfigurations.simple-vm.config.system.build.vm;
  };
}
