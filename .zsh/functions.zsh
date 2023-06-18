# Functions
# Create a new directory and enter it
mc () {
  mkdir -p "$@" && cd "$@"
}

# universal extract command
extract() {
  if [ -f "$1" ]; then
    local dir=""
    if [ -n "$2" ]; then
      dir="$2"
      mkdir -p "$dir"
    fi
    case "$1" in
      *.tar.bz2)   tar xvjf "$1" -C "$dir";;
      *.tar.gz)    tar xvzf "$1" -C "$dir";;
      *.tar.xz)    tar xvf "$1" -C "$dir";;
      *.bz2)       bunzip2 -v "$1";;
      *.rar)       rar xv "$1" "$dir";;
      *.gz)        gunzip -v "$1";;
      *.tar)       tar xvf "$1" -C "$dir";;
      *.tbz2)      tar xvjf "$1" -C "$dir";;
      *.tgz)       tar xvzf "$1" -C "$dir";;
      *.zip)       unzip "$1" -d "$dir";;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1" -o "$dir";;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function localip () {
  local eno1_output=$(ip addr show eno1)

  if ! echo "$eno1_output" | grep -q "DOWN"; then
    echo "$eno1_output"
  else
    ip addr show wlp4s0
  fi
}
