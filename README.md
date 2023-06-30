# .dotfiles

My . files for my thinkpad  

## Installation

Clone the repository:

```sh
git clone --bare https://github.com/zazedd/.dotfiles.git $HOME/.dotfiles
```

Define the alias in the current shell scope:

```sh
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Checkout the actual content from the git repository to your `$HOME`:

```sh
dotfiles checkout thinkpad
dotfiles checkout 
```

## Dependencies
Some of the dependencies are:

```sh
# general
oh-my-posh
oh-my-zsh
fastfetch
exa
gdu

# personal
alacritty
nvim
mpv
tmux

# extraction function
tar
bunzip2
rar
gunzip
unzip
uncompress
7z

```

