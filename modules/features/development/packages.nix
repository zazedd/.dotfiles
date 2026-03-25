let
  packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # tools
        claude-code

        # deps
        gmp
        gnumake
        pkg-config
      ];
    };
in
{
  flake.modules.nixos.dev.imports = [ packages ];
  flake.modules.darwin.dev.imports = [ packages ];
}
