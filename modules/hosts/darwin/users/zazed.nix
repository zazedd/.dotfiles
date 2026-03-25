{
  inputs,
  ...
}:
{
  flake.modules.darwin.shitbook = {
    imports = with inputs.self.modules.darwin; [
      zazed
    ];
  };
}
