
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

COMPLETION_WAITING_DOTS="true"

export HISTIGNORE="pwd:ls:cd"

export EDITOR="nvim"
export GIT_EDITOR="nvim --clean"

zstyle ':completion:*' menu select

# nix shortcuts
shell() {
    nix-shell '<nixpkgs>' -A "$1"
}

echo '\e[5 q' # line cursor

source <(fzf --zsh)
eval "$(zoxide init zsh)"

source ~/.zsh/keys.zsh
source ~/.zsh/functions.zsh
