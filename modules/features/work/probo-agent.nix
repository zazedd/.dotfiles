{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages = lib.optionalAttrs (system == "aarch64-darwin") {
        probo-agent = pkgs.callPackage ../../../pkgs/probo-agent { };
      };
    };

  flake.modules.darwin.work =
    { pkgs, ... }:
    let
      probo-agent = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.probo-agent;
    in
    {
      environment.systemPackages = [ probo-agent ];

      system.activationScripts.probo-agent.text = ''
        app_plist="/Applications/Probo Agent.app/Contents/Info.plist"
        installed_version=""

        if [ -f "$app_plist" ]; then
          installed_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_plist" 2>/dev/null || true)"
        fi

        if [ "$installed_version" != "${probo-agent.version}" ]; then
          echo "installing Probo Agent ${probo-agent.version} desktop app..."
          /usr/sbin/installer \
            -pkg "${probo-agent}/share/probo-agent/probo-agent.pkg" \
            -target /
        fi
      '';
    };
}
