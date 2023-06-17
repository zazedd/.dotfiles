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
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source ~/.zsh/theme.zsh

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
  z
)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------
# User configuration

# vi mode
bindkey -v

# Remove mode switching delay.
KEYTIMEOUT=5

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
       echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
         echo -ne '\e[5 q'
  fi
}

zle -N zle-keymap-select

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() {
  echo -ne '\e[5 q'
}

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

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Sudo alias hack
alias sudo="nocorrect sudo "

# Better default command replacement
alias mv="mv -iv"
alias mkdir="mkdir -p"
alias ddu="du -h"
alias du="gdu -n"
alias ls="/usr/bin/exa --color=always --group-directories-first"
alias la="/usr/bin/exa -l --color=always --group-directories-first"
alias l="/usr/bin/exa -lah --color=always --group-directories-first"
alias zyp="zypper"

alias nvid="neovide"
alias idea="/home/zazed/Documents/IDEA/bin/idea.sh"
alias t="tmux new-session \; send-keys "nvim" C-m \; neww \; split-window -v \; selectp -t 1  \; selectw -t 1"

alias weather="curl v2.wttr.in"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias gs="git status"
alias gcl="git clone"

alias ff="fastfetch --logo-color-1 3 --structure Title:Separator:OS:Host:Kernel:CPU:GPU:Uptime:Packages:Shell:Display:Terminal:TerminalFont:Disk:Battery:Memory --cpu-temp true --multithreading true"
alias rr="source ~/.zshrc"

eval "$(oh-my-posh init zsh --config ~/.spaceship.omp.json)"

export EDITOR=nvim

if [ ! "$TMUX" ]; then
  fastfetch --logo-color-1 3 --structure Title:Separator:OS:Host:Kernel:CPU:GPU:Uptime:Packages:Shell:Display:Terminal:TerminalFont:Disk:Battery:Memory --cpu-temp true --multithreading true
fi

if [[ -n $SSH_CONNECTION ]]; then
  echo "Don't break anything if you are a bad actor pls I beg you"
else
fi
