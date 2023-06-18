# Functions
# Create a new directory and enter it
mc () {
  mkdir -p "$@" && cd "$@"
}

# universal extract command
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1;;
      *.tar.gz)    tar xvzf $1;;
      *.tar.xz)    tar xvf $1;;
      *.bz2)       bunzip2 $1;;
      *.rar)       rar x $1;;
      *.gz)        gunzip $1;;
      *.tar)       tar xvf $1;;
      *.tbz2)      tar xvjf $1;;
      *.tgz)       tar xvzf $1;;
      *.zip)       unzip $1;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1;;
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
