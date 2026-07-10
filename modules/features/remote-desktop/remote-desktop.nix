{ ... }:
{
  flake.modules.nixos.remote-desktop =
    { lib, pkgs, ... }:
    let
      # krfb-virtualmonitor holds the virtual output open for as long as it
      # runs, so start it detached and tear it down on undo.
      virt-mon-up = pkgs.writeShellScriptBin "virt-mon-up" ''
        # Match the client's requested geometry/refresh (fall back to 4K144).
        w="''${SUNSHINE_CLIENT_WIDTH:-3840}"
        h="''${SUNSHINE_CLIENT_HEIGHT:-2160}"
        fps="''${SUNSHINE_CLIENT_FPS:-144}"

        ${pkgs.coreutils}/bin/nohup ${pkgs.kdePackages.krfb}/bin/krfb-virtualmonitor \
          --name Moonlight \
          --resolution "''${w}x''${h}" \
          --scale 1 \
          --password "" \
          --port 5900 \
          >/tmp/krfb-virtualmonitor.log 2>&1 &
        # give KWin a moment to register the new output before we retune it
        ${pkgs.coreutils}/bin/sleep 2

        # krfb creates the output at 60Hz; register the client's refresh as a
        # custom mode (refresh is in mHz: 144Hz -> 144000) and switch to it.
        kd=${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor
        "$kd" output.Virtual-Moonlight.addCustomMode."''${w}"."''${h}".$((fps * 1000)).full || true
        "$kd" output.Virtual-Moonlight.mode."''${w}x''${h}@''${fps}" || true
      '';

      virt-mon-down = pkgs.writeShellScriptBin "virt-mon-down" ''
        ${pkgs.procps}/bin/pkill -f krfb-virtualmonitor || true
      '';
    in
    {
      services.desktopManager.plasma6.enable = true;
      services.displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
        autoLogin = {
          enable = true;
          user = "zazed";
        };
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      services.sunshine = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        capSysAdmin = true;
        package = pkgs.sunshine.override {
          cudaSupport = true;
          cudaPackages = pkgs.cudaPackages;
        };
        settings = {
          capture = "kwin";
          csrf_allowed_origins = "https://ricardogoncalves:47990";

          global_prep_cmd = ''[{"do":"${virt-mon-up}/bin/virt-mon-up","undo":"${virt-mon-down}/bin/virt-mon-down","elevated":"false"}]'';
          output_name = "Virtual-Moonlight";
        };
      };

      systemd.user.services.sunshine.environment.LD_LIBRARY_PATH = lib.mkForce "/run/opengl-driver/lib";

      environment.systemPackages = with pkgs; [
        kdePackages.krfb
        virt-mon-up
        virt-mon-down
      ];

      boot.kernelModules = [ "uinput" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      '';

      # The desktop is always-on so Moonlight can connect any time, but KDE's
      # background pollers keep waking the spun-down storage HDDs. Neuter them:
      environment.plasma6.excludePackages = [ pkgs.kdePackages.plasma-disks ];
      environment.etc."xdg/kded5rc".text = ''
        [Module-freespacenotifier]
        autoload=false

        [Module-device_automounter]
        autoload=false
      '';
    };
}
