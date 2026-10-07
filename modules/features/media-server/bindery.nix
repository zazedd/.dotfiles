{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        bindery = pkgs.callPackage ../../../pkgs/bindery { };
      };
    };

  flake.modules.nixos.bindery =
    { pkgs, ... }:
    {
      imports = [ ../../../pkgs/bindery/module.nix ];

      services.bindery.package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bindery;
    };
}
