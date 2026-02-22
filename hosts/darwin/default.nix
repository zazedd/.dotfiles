{
  config,
  pkgs,
  ...
}@inputs:

let
  user = "zazed";
in

{

  imports = [
    ../../profiles/darwin/home-manager.nix
    ../../profiles/shared/default.nix
    ../../profiles/shared/cachix
  ];

  system.primaryUser = user;

  # Auto upgrade nix package and the daemon service.
  # Setup user, packages, programs
  nix = {
    # package = pkgs.nixVersions.git;
    settings.trusted-users = [
      "@admin"
      "${user}"
    ];

    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            # diskSize = 40 * 1024;
            memorySize = 6 * 1024;
          };
          cores = 6;
        };
      };
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = (import ../../profiles/shared/packages.nix { inherit pkgs; });

  # Enable fonts dir
  fonts = {
    packages = with pkgs.nerd-fonts; [
      fira-code
      iosevka
    ];
  };

  system = {
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        NSWindowShouldDragOnGesture = true;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.25;
        show-recents = false;
        launchanim = true;
        orientation = "right";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        # TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
