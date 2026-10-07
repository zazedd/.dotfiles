{
  flake.modules.darwin.trading =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = "zazed";
      home = config.users.users.${user}.home;

      trader-workstation-installer = pkgs.brewCasks.trader-workstation.overrideAttrs {
        pname = "trader-workstation-installer";

        src = pkgs.fetchurl {
          url = "https://download2.interactivebrokers.com/installers/tws/latest/tws-latest-macos-arm.dmg";
          hash = "sha256-PDyjEWFgiyi/jN7YV5AXvQAYiI8n20GhIY2u576LXMs=";
        };

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/share/trader-workstation"
          cp -R "Trader Workstation Installer.app" "$out/share/trader-workstation/"

          runHook postInstall
        '';
      };
    in
    {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        install_dir="/Applications/Trader Workstation"
        version_file="$install_dir/.nix-version"
        installed_version=""

        if [ -f "$version_file" ]; then
          installed_version="$(<"$version_file")"
        fi

        if [ "$installed_version" != "${trader-workstation-installer.version}" ]; then
          echo "installing Trader Workstation ${trader-workstation-installer.version}..."
          "${trader-workstation-installer}/share/trader-workstation/Trader Workstation Installer.app/Contents/MacOS/JavaApplicationStub" \
            -J-Duser.home=${home} \
            -dir "$install_dir" \
            -q

          echo "${trader-workstation-installer.version}" > "$version_file"
          chown -R ${user}:staff "$install_dir"
        fi
      '';
    };
}
