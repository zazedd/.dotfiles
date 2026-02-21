# Functions
# Create a new directory and enter it
mc () {
  mkdir -p "$@" && cd "$@"
}

nixvm () {
  nix run ~/.dotfiles/#simple-vm
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
