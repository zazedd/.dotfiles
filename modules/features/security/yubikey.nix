{
  flake.modules.nixos.security = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ yubioath-flutter ];
  };

  flake.modules.darwin.security = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ brewCasks.yubico-authenticator ];
  };

  flake.modules.homeManager.security = { };
}
