{ self, ... }:
{
  flake.modules.homeManager.devbox = {
    imports = with self.modules.homeManager; [
      system-minimal
      shell
    ];

    home.username = "me";
  };
}
