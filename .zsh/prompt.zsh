# Prompt
eval "$(oh-my-posh init zsh --config ~/.spaceship.omp.json)"

export EDITOR=nvim

if [ ! "$TMUX" ]; then
  fastfetch --logo-color-1 3 --structure Title:Separator:OS:Host:Kernel:CPU:GPU:Uptime:Packages:Shell:Display:Terminal:TerminalFont:Disk:Battery:Memory --cpu-temp true --multithreading true
fi

if [[ -n $SSH_CONNECTION ]]; then
  echo "Don't break anything if you are a bad actor pls I beg you"
else
fi
