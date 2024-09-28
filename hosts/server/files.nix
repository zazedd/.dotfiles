{ pkgs, ... }:

with pkgs;

let
  vanillatweaks = fetchurl {
    url = "https://vanillatweaks.net/share#qbpkiO";
    hash = "sha256-JgPS/ORYMONimuy+AA40N4RwA88eLouT6xU0jarU6No=";
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

  extractedZipEntries = lib.attrValues (
    lib.genAttrs (builtins.attrNames (builtins.readDir "${extractedTweaks}/srv/minecraft/datapacks"))
      (fileName: {
        inherit fileName;
        src = "${extractedTweaks}/srv/minecraft/datapacks/${fileName}";
      })
  );

  # Generate the environment.etc entries from the extracted zip files
  etcEntries = lib.listToAttrs (
    map (zip: {
      name = "srv/minecraft/datapacks/${zip.fileName}";
      value = builtins.readFile zip.src;
    }) extractedZipEntries
  );

  infinity_mending = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB=";
  };
  better_item_frames = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC=";
  };
  disenchanting = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD=";
  };
  cauldron_concrete = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE=";
  };
  tpa = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF=";
  };
  armored_elytra = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG=";
  };
  no_ghast_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH=";
  };
  no_enderman_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI=";
  };
  no_creeper_grief = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJ=";
  };
  afk = fetchurl {
    url = "";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK=";
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
  } // etcEntries;
}
