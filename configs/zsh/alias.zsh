# Alias
# Sudo alias hack
alias sudo="nocorrect sudo "

# Better default command replacement
alias mv="mv -iv"
alias mkdir="mkdir -p"
alias ddu="du -h"
alias du="gdu-go -n"
alias ls="/opt/homebrew/bin/exa --color=always --group-directories-first"
alias la="/opt/homebrew/bin/exa -l --color=always --group-directories-first"
alias l="/opt/homebrew/bin/exa -lah --color=always --group-directories-first"
alias ldir="/opt/homebrew/bin/exa --color=always --group-directories-first -lahd */"
alias lhdir="/opt/homebrew/bin/exa --color=always --group-directories-first -lad .*/"

alias nvid="neovide"
alias v="nvim"
alias t="tmux new-session \; send-keys "nvim" C-m \; neww \; split-window -v \; selectp -t 1  \; selectw -t 1"

alias weather="curl v2.wttr.in"

alias wakesv="sudo ether-wake -i eno1 14:da:e9:6d:5d:c9 -b 192.168.0.255"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gcl="git clone"

alias ff="fastfetch --logo-color-1 3 --structure Title:Separator:OS:Host:Kernel:CPU:GPU:Uptime:Packages:Shell:Display:Terminal:TerminalFont:Disk:Battery:Memory --cpu-temp true --multithreading true"
alias rr="source ~/.zshrc"
