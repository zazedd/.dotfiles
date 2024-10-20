{ pkgs, ... }:
{
  enable = true;
  prefix = "C-Space";
  terminal = "tmux-256color";
  keyMode = "vi";
  customPaneNavigationAndResize = true;
  mouse = true;
  plugins = with pkgs.tmuxPlugins; [
    {
      plugin = tmux-nova;
      extraConfig = ''
        set -g @nova-nerdfonts true
        set -g @nova-nerdfonts-left ▌
        set -g @nova-nerdfonts-right ▐

        set -g @nova-pane-active-border-style "#44475a"
        set -g @nova-pane-border-style "#282a36"
        set -g @nova-status-style-bg "#181818"
        set -g @nova-status-style-fg "#d8dee9"
        set -g @nova-status-style-active-bg "#89c0d0"
        set -g @nova-status-style-active-fg "#2e3540"
        set -g @nova-status-style-double-bg "#2d3540"

        set -g @nova-pane "#I#{?pane_in_mode, #{pane_mode},}\u00A0>>=\u00A0#W"

        set -g @nova-segment-mode "#{?client_prefix,,󰘩}"
        set -g @nova-segment-mode-colors "#78a2c1 #2e3440"

        set -g @nova-segment-whoami "#(whoami)@#h"
        set -g @nova-segment-whoami-colors "#78a2c1 #2e3440"

        set -g @nova-rows 0
        set -g @nova-segments-0-left "mode"
        set -g @nova-segments-0-right "whoami"
      '';
    }
    sensible
    vim-tmux-navigator
    better-mouse-mode
  ];
  baseIndex = 1;
  extraConfig = ''
    # True color
    set -as terminal-features ",alacritty*:RGB"

    bind-key -n C-Delete send-keys -X backward-delete-word

    set-option -g renumber-windows on

    # open pane in same dir
    bind '"' split-window -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"

    # Shift Alt vim keys to switch windows
    bind -n M-H previous-window
    bind -n M-L next-window
  '';
}
