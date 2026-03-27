
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

# Functions
# Create a new directory and enter it
mc () {
  mkdir -p "$@" && cd "$@"
}

nix-shell-dev() {
  local dev_installables=()
  local shell_installables=()
  for pkg in "$@"; do
    dev_installables+=("nixpkgs#${pkg}.dev")
    shell_installables+=("nixpkgs#${pkg}")
  done

  local dev_paths
  dev_paths=$(
    nix build --no-link --print-out-paths "${dev_installables[@]}"
  )

  local extra_ld extra_pc
  extra_ld=$(echo "$dev_paths" | awk '{print $0 "/lib"}' | paste -sd:)
  extra_pc=$(echo "$dev_paths" | awk '{print $0 "/lib/pkgconfig"}' | paste -sd:)

  LD_LIBRARY_PATH="${extra_ld}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  PKG_CONFIG_PATH="${extra_pc}${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}" \
    nix shell "${shell_installables[@]}"
}

# universal extract command
ext () {
  if [ -f "$1" ]; then
    local file="$1"
    if [ -n "$2" ]; then
      file=../"$1"
      mkdir -p "$2"
      cd "$2"
    fi
    case "$1" in
      *.tar.bz2)   tar xvjf "$file";;
      *.tar.gz)    tar xvzf "$file";;
      *.tar.xz)    tar xvf "$file";;
      *.bz2)       bunzip2 -v "$file";;
      *.rar)       rar x "$file";;
      *.gz)        gunzip -v "$file";;
      *.tar)       tar xvf "$file";;
      *.tbz2)      tar xvjf "$file";;
      *.tgz)       tar xvzf "$file";;
      *.zip)       unzip "$file";;
      *.Z)         uncompress "$file";;
      *.z)         uncompress "$file";;
      *.7z)        7z x "$file";;
      *)           echo "'$1' cannot be extracted via ext ()" ;;
    esac
    if [ -n "$2" ]; then
      cd ..
    fi
  else
    echo "'$1' is not a valid file"
  fi
}

function replace_multiple_dots() {
  local dots=$LBUFFER[-3,-1]
  if [[ $dots =~ "^[ //\"']?\.\.$" ]]; then
    LBUFFER=$LBUFFER[1,-3]'../.'
  fi
  zle self-insert
}

zle -N replace_multiple_dots
bindkey "." replace_multiple_dots


