{ self, config, ... }:
{
  flake.meta.users = {
    zazed =
      let
        n = "zazed";
      in
      {
        name = n;
        email = "leomendesantos@gmail.com";
        username = n;
        authorizedKeys = [ ];
      };
  };

  flake.modules = {
    nixos.zazed =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [ ];
        programs.zsh.enable = true;

        users.users.zazed = {
          description = config.flake.meta.users.zazed.name;
          isNormalUser = true;
          createHome = true;
          shell = pkgs.zsh;
          extraGroups = [
            "wheel"
            "audio"
            "input"
            "video"
            "seat"
            "davfs2"
            "vboxusers"
            "networkmanager"
            "libvirtd"
          ];
        };
      };

    darwin.zazed =
      { pkgs, ... }:
      {
        users.users.zazed = {
          home = "/Users/zazed";
          shell = pkgs.zsh;
        };

        home-manager.users.zazed = {
          imports = [
            self.modules.homeManager.zazed
          ];
        };

        system.primaryUser = "zazed";
      };

    homeManager.zazed =
      { pkgs, ... }:
      {
        imports = with self.modules.homeManager; [ system-desktop ];
        home.packages = with pkgs; [ ];
      };
  };
}
