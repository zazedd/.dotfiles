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
    nixos.zazed = {
      imports = with self.modules.nixos; [ ];
      users.users.zazed = {
        description = config.flake.meta.users.zazed.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "davfs2"
          "vboxusers"
          "networkmanager"
        ];
      };
    };

    darwin.zazed = {
      imports = with self.modules.darwin; [ ];
    };

    homeManager.zazed =
      { pkgs, ... }:
      {
        imports = with self.modules.homeManager; [ system-desktop ];
        home.packages = with pkgs; [ ];
      };
  };
}
