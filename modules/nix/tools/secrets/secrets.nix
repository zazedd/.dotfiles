{
  inputs,
  config,
  ...
}:
let
  username = config.flake.meta.users.zazed.username;
in
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    };

  flake.modules.darwin.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.darwinModules.sops ];
      environment.systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    };

  flake.modules.homeManager.secrets =
    { config, pkgs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModule ];
      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
}
