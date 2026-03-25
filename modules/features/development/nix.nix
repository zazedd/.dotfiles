{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixfmt
        nixd

        nix-output-monitor
        nix-fast-build
        nix-tree
      ];
      programs.nh.enable = true;
    };
}
