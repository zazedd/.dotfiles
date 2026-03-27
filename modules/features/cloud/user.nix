{ lib, ... }:
{
  flake.modules.nixos.cloud = {
    users.groups.cloud = { };

    users.users.copyparty = {
      description = "Service user for copyparty";
      group = "cloud";
      isSystemUser = true;
    };

    users.users.paperless = {
      description = "Service user for paperless-ngx";
      group = lib.mkForce "cloud";
      isSystemUser = true;
    };
  };
}
