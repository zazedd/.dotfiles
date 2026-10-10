{
  flake.modules.nixos.cloud =
    { config, ... }:
    {
      # torchcodec's MP3 encoder comparison is sensitive to FFmpeg's floating-
      # point output and currently fails on x86_64-linux despite producing valid
      # audio. Keep the rest of its test suite enabled.
      nixpkgs.overlays = [
        (_final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (_pythonFinal: pythonPrev: {
              torchcodec = pythonPrev.torchcodec.overridePythonAttrs (old: {
                disabledTests = (old.disabledTests or [ ]) ++ [ "test_audio_against_cli" ];
              });
            })
          ];
        })
      ];

      sops.secrets."paperless" = {
        owner = "paperless";
      };

      services.paperless = {
        enable = true;
        domain = "paperless.leoms.dev";
        dataDir = "/data/cloud/documents";
        port = config.registry.paperless.port;
        user = "paperless";
        passwordFile = config.sops.secrets."paperless".path;
      };

      email-on-failure = {
        paperless-consumer = true;
        paperless-scheduler = true;
        paperless-task-queue = true;
        paperless-web = true;
        redis-paperless = true;
      };
    };

  flake.modules.nixos.reverse-proxy = {
    registry.paperless.port = 7999;
  };
}
