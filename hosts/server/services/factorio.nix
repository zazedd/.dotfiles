{ my_pkgs, ... }:
{
  enable = true;
  admins = [ ];
  game-password = "123";
  game-name = "idiots";
  lan = true;
  port = 34197;
  package = my_pkgs.factorio-headless;
}
