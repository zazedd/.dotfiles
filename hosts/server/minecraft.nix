{ pkgs }:

with pkgs;

let

  # DATAPACKS
  vanillatweaks = stdenv.mkDerivation {
    name = "extract-vanilla-tweaks";
    src = fetchzip {
      url = "https://vanillatweaks.net/download/VanillaTweaks_d495683_UNZIP_ME.zip";
      hash = "sha256-BcdTOdq8UmoglyhKRqEmO3lOvA19FhVD4+kfbyTChQc=";
      stripRoot = false;
    };

    nativeBuildInputs = [ unzip ];

    buildPhase = ''
      ls $src
    '';

    installPhase = ''
      mkdir -p $out/zips/
      cp -r * $out/zips/
    '';
  };

  vanillatweaksFiles = builtins.attrNames (builtins.readDir "${vanillatweaks}/zips");

  infinity_mending = fetchurl {
    url = "https://cdn.modrinth.com/data/ntU7wRQ0/versions/7XUXYlw9/Infinity%20mending%201.21.zip";
    hash = "sha256-suNV/OINhuqRch2zffQchoOKAOSB0uI+Q3N+80+4l9c=";
  };

  better_item_frames = fetchurl {
    url = "https://cdn.modrinth.com/data/uE97WYCE/versions/j1fdZZsL/PK_Better_Item_Frames_V.3.0.3_MC_1.21.zip";
    hash = "sha256-3iLZLE0kAuSQP/CejYS7zFAEgGyi8t/ruPb7FcwtP6g=";
  };

  disenchanting = fetchurl {
    url = "https://cdn.modrinth.com/data/qwgbtiVV/versions/dXVQ7RTB/disenchanting_book-v2.zip";
    hash = "sha256-kPc8Mu1k+oyf8NcAFFFTFa469ip+Wb/9DRJy7kItaf0=";
  };

  cauldron_concrete = fetchurl {
    url = "https://cdn.modrinth.com/data/sKa9BOA6/versions/ikcyQYKK/CauldronConcretePowder%20%5Bv1.1.0%5D.zip";
    hash = "sha256-2g6cbZ7d+oyCGOgLliRsxD5o66K0o05QQnpDkF/TeVI=";
  };

  tpa = fetchurl {
    url = "https://cdn.modrinth.com/data/6h6n9XJ9/versions/84BDEAlA/1.3.1-TPA_dtpk-1.21.zip";
    hash = "sha256-LqlKaD1gOhUeYZkHu2uga999O9wQlW6cUBNaxP7S5ms=";
  };

  armored_elytra = fetchurl {
    url = "https://cdn.modrinth.com/data/xfDKtwBJ/versions/nGurJNeb/armored-elytra-1.4.2.zip";
    hash = "sha256-+HhHSKt6LXt0kJF1bRud9XNzIkzXCaZGp+DFKLND8fo=";
  };

  no_ghast_grief = fetchurl {
    url = "https://cdn.modrinth.com/data/x4vSQ0E8/versions/7mxI8wd9/PK_No_Ghast_Grief_V.3.0.2_MC_1.21.zip";
    hash = "sha256-SNgSzOVsKu4NLIsELm8J122EnzCdxuPft9RsLKi2wSI=";
  };

  no_enderman_grief = fetchurl {
    url = "https://cdn.modrinth.com/data/ss02V75k/versions/kZzRumMo/NoEndermanGrief-%5B1.21%5D-v.2.1.2.zip";
    hash = "sha256-DNHPdJ/4wg3ZOkWK8Aqiw+S+KDczJkt1kTJvexmuh28=";
  };

  no_creeper_grief = fetchurl {
    url = "https://cdn.modrinth.com/data/WCR1qfos/versions/coJcFs0W/PK_No_Creeper_Grief_V.3.0.1_MC_1.21.zip";
    hash = "sha256-AALdCNaLpQFZ4Glc0usyzWBwuKNxCkwHkxYao3muv2g=";
  };

  afk = fetchurl {
    url = "https://cdn.modrinth.com/data/OZdgwUpA/versions/NHGkiknR/afk%2B1.1.1%2Bmc1.18.x-1.21.0.zip";
    hash = "sha256-9g4SOAmnbSRRX5TlwVRRBDRUtJpGmhiYtynMeixOtRc=";
  };

  # PLUGINS
  marriage = fetchurl {
    url = "https://dev.bukkit.org/projects/marriage-master/files/5543582/download";
    hash = "sha256-cE/SyKTJ8umoaQ5788fdpkZ5CNUNP0RPap5xI2e1Rwg=";
  };

  changeskin = fetchurl {
    url = "https://dev.bukkit.org/projects/changeskin/files/4226675/download";
    hash = "sha256-e/zLN/wIG/GerHB9vksI6xnpDEkDfufW0mBHI8/5SVY=";
  };

  laggremover = fetchurl {
    url = "https://dev.bukkit.org/projects/laggremover/files/2744510/download";
    hash = "sha256-xIajcL4SKKiSbM96263jmRtJtlOl1jqgZjrIFaq2Hz4=";
  };

  tree-capitator = fetchurl {
    url = "https://dev.bukkit.org/projects/cristichis-tree-capitator/files/4810402/download";
    hash = "sha256-GVz0lrLVnWvSkcXLxSdeYyrnn4ctyGtVxpKZFphRUEk=";
  };

  autosaveworld = fetchurl {
    url = "https://dev.bukkit.org/projects/autosaveworld/files/2365294/download";
    hash = "sha256-XfuzyPiOUj5bmjcjNQfTQ8k3Nw5PJh0FftGWhRg71LY=";
  };

  veinminer = fetchurl {
    url = "https://cdn.modrinth.com/data/OhduvhIc/versions/JTRAemaW/veinminer-paper-2.1.5.jar";
    hash = "sha256-0fLI28p4Sss2doV4KCM0K5rgQAKgFEub2fXMhX00bZQ=";
  };

  memory = "8120";
  JVM_OPTS = lib.concatStringsSep " " [
    "-Xms${memory}M"
    "-Xmx${memory}M"
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
  ];
in
{
  enable = true;
  eula = true;
  servers.estupidos = {
    enable = true;
    package = pkgs.callPackage ./purpur.nix { inherit pkgs JVM_OPTS; };
    jvmOpts = "";

    serverProperties = {
      online = "false";
      gamemode = "survival";
      difficulty = "normal";
      simulation-distance = "12";
      server-port = "42069";
      level-seed = "199";
    };

    files = {
      "ops.json" = pkgs.writeTextFile {
        name = "ops.json";
        text = ''
          [
            {
              "uuid": "aa209659-f53a-46a7-a535-e68bba0180f4",
              "name": "funcaoEretil",
              "level": 4,
              "bypassesPlayerLimit": false
            }
          ]
        '';
      };
    };

    symlinks =
      {
        "allowed_symlinks.txt" = pkgs.writeText "allowed_symlinks.txt" "/nix/store";
        "server-icon.png" = ../../configs/minecraft/server-icon.png;

        "config/paper-global.yml" = ../../configs/minecraft/paper.yml;

        # plugins
        "plugins/marriage.jar" = marriage;
        "plugins/changeskin.jar" = changeskin;
        "plugins/laggremover.jar" = laggremover;
        "plugins/tree-capitator.jar" = tree-capitator;
        "plugins/autosaveworld.jar" = autosaveworld;
        "plugins/veinminer.jar" = veinminer;

        "plugins/AutoSaveWorld/config.yml" = ../../configs/minecraft/backup-config.yml;

        # datapacks
        "world/datapacks/infinity_mending.zip" = infinity_mending;
        "world/datapacks/better_item_frames.zip" = better_item_frames;
        "world/datapacks/disenchanting.zip" = disenchanting;
        "world/datapacks/cauldron_concrete.zip" = cauldron_concrete;
        "world/datapacks/tpa.zip" = tpa;
        "world/datapacks/armored_elytra.zip" = armored_elytra;
        "world/datapacks/no_ghast_grief.zip" = no_ghast_grief;
        "world/datapacks/no_enderman_grief.zip" = no_enderman_grief;
        "world/datapacks/no_creeper_grief.zip" = no_creeper_grief;
        "world/datapacks/afk.zip" = afk;
      }
      // builtins.listToAttrs (
        map (file: {
          name = "world/datapacks/${file}";
          value = "${vanillatweaks}/zips/${file}";
        }) vanillatweaksFiles
      );
  };
}