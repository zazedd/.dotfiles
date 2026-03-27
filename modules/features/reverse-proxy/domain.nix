{
  flake.modules.nixos.domain =
    { lib, ... }:
    {
      options.domain = lib.mkOption {
        type = lib.types.str;
        description = "primary domain for a host's services (e.g. \"example.com\").";
      };
    };
}
