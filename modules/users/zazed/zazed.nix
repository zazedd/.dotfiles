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
        key = "";
        username = n;
        keygrip = [ ];
        authorizedKeys = [ ];
      };
  };

  flake.modules = {
    nixos.zazed = {
      imports = with self.modules.nixos; [ ];
      users.users.zazed = {
        description = config.flake.meta.users.user.name;
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
        imports = with self.modules.homeManager; [ ];
        home.packages = with pkgs; [ ];
      };
  };
}
