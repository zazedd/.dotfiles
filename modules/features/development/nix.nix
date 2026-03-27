{
  flake.modules.homeManager.dev =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        nixfmt
        nixd

        nix-output-monitor
        nix-fast-build
        nix-tree
      ];
      programs.nh = {
        enable = true;
        flake = "${config.home.homeDirectory}/.dotfiles";
      };
    };
}
