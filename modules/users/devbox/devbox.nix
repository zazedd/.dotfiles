{ self, ... }:
{
  flake.modules.homeManager.devbox = {
    imports = with self.modules.homeManager; [
      system-minimal
      ssh
      shell
    ];

    home.username = "me";
  };
}
