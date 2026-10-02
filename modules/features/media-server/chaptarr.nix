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
        chaptarr = pkgs.callPackage ../../../pkgs/chaptarr { };
      };
    };

  flake.modules.nixos.chaptarr =
    { pkgs, ... }:
    {
      imports = [ ../../../pkgs/chaptarr/module.nix ];

      services.chaptarr.package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.chaptarr;
    };
}
