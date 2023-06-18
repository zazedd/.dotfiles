# Alias 
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
alias v="nvim"
alias idea="/home/zazed/Documents/IDEA/bin/idea.sh"
alias t="tmux new-session \; send-keys "nvim" C-m \; neww \; split-window -v \; selectp -t 1  \; selectw -t 1"

alias weather="curl v2.wttr.in"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gcl="git clone"

alias ff="fastfetch --logo-color-1 3 --structure Title:Separator:OS:Host:Kernel:CPU:GPU:Uptime:Packages:Shell:Display:Terminal:TerminalFont:Disk:Battery:Memory --cpu-temp true --multithreading true"
alias rr="source ~/.zshrc"
