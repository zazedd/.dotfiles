{ inputs, ... }:
{
  flake.modules.nixos.lenovo = {
    imports = with inputs.self.modules.nixos; [
      zazed
    ];
  };
}
