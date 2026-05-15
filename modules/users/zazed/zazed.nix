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
        homeLinux = "/Users/${n}";
        homeDarwin = "/home/${n}";
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
        users.users.zazed = {
          home = "/Users/zazed";
          shell = self.packages.${pkgs.stdenv.hostPlatform.system}.fish;
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
