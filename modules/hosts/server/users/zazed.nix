{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [
      zazed
    ];
  };
}
