{
  inputs,
  ...
}:
{
  flake.modules.darwin.macbook = {
    imports = with inputs.self.modules.darwin; [
      zazed
    ];

    home-manager.users.zazed = { };
  };
}
