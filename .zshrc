# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
HIST_STAMPS=""
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# problems with multiple shell instances
setopt inc_append_history
setopt share_history

# no more duplicate commands in history
setopt histignorealldups

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source ~/.zsh/theme.zsh

# syntax highlighing on tab completion
zstyle ':completion:*' menu select
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

plugins=(
	git
  sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
  z
)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------
# User configuration

export EDITOR=nvim

source ~/.zsh/keys.zsh

source ~/.zsh/vimode.zsh

source ~/.zsh/functions.zsh

source ~/.zsh/alias.zsh

source ~/.zsh/prompt.zsh
