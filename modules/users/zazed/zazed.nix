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
        homeLinux = "/home/${n}";
        homeDarwin = "/Users/${n}";
      };
  };

  flake.modules = {
    nixos.zazed =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [ ];
        programs.fish = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.fish;
        };

        users.users.zazed = {
          description = config.flake.meta.users.zazed.name;
          isNormalUser = true;
          createHome = true;
          shell = self.packages.${pkgs.stdenv.hostPlatform.system}.fish;
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
        programs.fish = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.fish;
        };

        users.users.zazed = {
          home = "/Users/zazed";
          shell = "/run/current-system/sw/bin/fish";
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
