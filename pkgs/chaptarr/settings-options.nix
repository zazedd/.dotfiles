{ lib, pkgs }:
{
  settings = lib.mkOption {
    type = lib.types.submodule {
      freeformType = (pkgs.formats.ini { }).type;
      options = {
        update = {
          mechanism = lib.mkOption {
            type =
              with lib.types;
              nullOr (enum [
                "external"
                "builtIn"
                "script"
              ]);
            default = "external";
            description = "Update mechanism to use.";
          };
          automatically = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether Chaptarr may automatically install updates.";
          };
        };
        server.port = lib.mkOption {
          type = lib.types.port;
          default = 8789;
          description = "Port for the Chaptarr web interface.";
        };
        log.analyticsEnabled = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to send anonymous usage data.";
        };
      };
    };
    default = { };
    description = ''
      Chaptarr settings represented as nested attributes and passed as
      `CHAPTARR__SECTION__KEY` environment variables. Do not put secrets here,
      because this configuration is stored in the world-readable Nix store.
    '';
  };

  environmentFiles = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ ];
    description = ''
      Files containing secret environment variables. Each line should use the
      `CHAPTARR__SECTION__KEY=value` format.
    '';
  };

  toEnvironment =
    settings:
    lib.pipe settings [
      (lib.mapAttrsRecursive (
        path: value:
        lib.optionalAttrs (value != null) {
          name = lib.toUpper "CHAPTARR__${lib.concatStringsSep "__" path}";
          value = toString (if lib.isBool value then lib.boolToString value else value);
        }
      ))
      (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false))
      lib.listToAttrs
    ];
}
