{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnsupportedSystem = true;
          allowBroken = true;
        };
      };
    };
}
