# .dotfiles

My . files
The stuff that is in the .dotfiles_extra I am not currently using.

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
dotfiles checkout
```
