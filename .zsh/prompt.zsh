# Prompt
eval "$(oh-my-posh init zsh --config ~/.spaceship.omp.json)"

if [ ! "$TMUX" ]; then
  neofetch
fi

if [[ -n $SSH_CONNECTION ]]; then
  echo "Don't break anything if you are a bad actor pls I beg you"
else
fi
