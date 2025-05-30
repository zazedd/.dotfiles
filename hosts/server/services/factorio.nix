{ my_nixpkgs, ... }:
{
  enable = true;
  admins = [ ];
  game-password = "123";
  game-name = "idiots";
  lan = true;
  port = 34197;
  package = my_nixpkgs.factorio-headless;
}
