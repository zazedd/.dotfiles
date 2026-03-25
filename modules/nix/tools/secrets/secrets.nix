{
  inputs,
  config,
  ...
}:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      sops.age.keyFile = "${config.flake.meta.home.dir}/.config/sops/age/keys.txt";
    };

  flake.modules.darwin.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.darwinModules.sops ];
      environment.systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      sops.age.keyFile = "${config.flake.meta.home.dir}/.config/sops/age/keys.txt";
    };

  flake.modules.homeManager.secrets =
    { ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModule ];
      sops.age.keyFile = "${config.flake.meta.home.dir}/.config/sops/age/keys.txt";
    };
}
