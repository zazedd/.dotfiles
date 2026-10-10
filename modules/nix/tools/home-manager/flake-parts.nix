{ inputs, lib, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  perSystem =
    { system, ... }:
    lib.mkIf (system == "x86_64-linux") {
      checks = {
        home-devbox = inputs.self.homeConfigurations.devbox.activationPackage;
        home-zazed = inputs.self.homeConfigurations.zazed.activationPackage;
      };
    };
}
