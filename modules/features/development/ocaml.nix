{
  flake.modules.homeManager.dev =
    { config, ... }:
    {
      programs.opam = {
        enable = true;
        enableZshIntegration = false;
      };

      programs.zsh.initContent = ''
        if [[ -f "''${OPAMROOT:-$HOME/.opam}/config" ]]; then
          eval "$(${config.programs.opam.package}/bin/opam env --shell=zsh)"
        fi
      '';
    };
}
