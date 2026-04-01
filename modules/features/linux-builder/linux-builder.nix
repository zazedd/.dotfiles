{
  flake.modules.darwin.linux-builder = {
    nix.linux-builder = {
      enable = true;
      ephemeral = true;
      systems = [ "aarch64-linux " ];
      config.virtualisation.cores = 8;
    };
  };
}
