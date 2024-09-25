{ pkgs, ... }:

with pkgs;

let
  vanillatweaks = fetchurl {
    url = "https://vanillatweaks.net/share#qbpkiO";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  extractVanillaTweaks =
    vanillatweaks:
    stdenv.mkDerivation {
      name = "extract-vanilla-tweaks";

      buildCommand = ''
        mkdir -p $out/srv/minecraft/datapacks
        unzip ${vanillatweaks} -d tempdir

        # Move inner zip files to the final output directory
        for zip in tempdir/*.zip; do
          mv "$zip" $out/srv/minecraft/datapacks/
        done
      '';
    };

  extractedTweaks = extractVanillaTweaks vanillatweaks;

  zipsToEtc =
    let
      zipFiles = builtins.filter (file: lib.hasSuffix ".zip" file) (
        builtins.listFiles "${extractedTweaks}/srv/minecraft/datapacks"
      );

      toEtcEntry = file: {
        "srv/minecraft/datapacks/${lib.basename file}" = builtins.readFile file;
      };
    in
    lib.flatten (map toEtcEntry zipFiles);

  infinity_mending = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  better_item_frames = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  disenchanting = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  cauldron_concrete = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  tpa = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  armored_elytra = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  no_ghast_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  no_enderman_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  no_creeper_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  afk = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
in
{
  environment.etc = {
    "srv/minecraft/datapacks/infinity_mending.zip" = builtins.readFile infinity_mending;
    "srv/minecraft/datapacks/better_item_frames.zip" = builtins.readFile better_item_frames;
    "srv/minecraft/datapacks/disenchanting.zip" = builtins.readFile disenchanting;
    "srv/minecraft/datapacks/cauldron_concrete.zip" = builtins.readFile cauldron_concrete;
    "srv/minecraft/datapacks/tpa.zip" = builtins.readFile tpa;
    "srv/minecraft/datapacks/armored_elytra.zip" = builtins.readFile armored_elytra;
    "srv/minecraft/datapacks/no_ghast_grief.zip" = builtins.readFile no_ghast_grief;
    "srv/minecraft/datapacks/no_enderman_grief.zip" = builtins.readFile no_enderman_grief;
    "srv/minecraft/datapacks/no_creeper_grief.zip" = builtins.readFile no_creeper_grief;
    "srv/minecraft/datapacks/afk.zip" = builtins.readFile afk;
  } // zipsToEtc;
}
