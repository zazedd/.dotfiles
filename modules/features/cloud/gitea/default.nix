{
  flake.modules.nixos.reverse-proxy.registry = {
    git.port = 3000;
    git-mirror.port = 4321;
  };
}
