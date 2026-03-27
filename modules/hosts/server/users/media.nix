{
  flake.modules.nixos.server = {
    users.users.media = {
      isSystemUser = true;
      description = "media user for arr services";
      group = "media";
      extraGroups = [
        "render"
        "video"
      ];
    };

    users.groups.media = { };
  };
}
