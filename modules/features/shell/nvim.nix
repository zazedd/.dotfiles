{ inputs, ... }:
{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
        withPython3 = true;
      };

      xdg.configFile.nvim = {
        source = ../../../configs/nvim;
        recursive = true;
      };
    };
}
