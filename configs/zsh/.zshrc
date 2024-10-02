
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

if [[ $(uname) == "Darwin" ]]; then
    [[ ! -r /Users/zazed/.opam/opam-init/init.zsh ]] || source /Users/zazed/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
else
    [[ ! -r /home/zazed/.opam/opam-init/init.zsh ]] || source /home/zazed/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
fi

export PATH=$PATH:/run/current-system/sw/bin

export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time
COMPLETION_WAITING_DOTS="true"

export HISTIGNORE="pwd:ls:cd"

export EDITOR="nvim"
export GIT_EDITOR="nvim --clean"

zstyle ':completion:*' menu select

# nix shortcuts
shell() {
    nix-shell '<nixpkgs>' -A "$1"
}

eval "$(zoxide init zsh)"

source ~/.zsh/theme.zsh
source ~/.zsh/keys.zsh
source ~/.zsh/vimode.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/prompt.zsh
