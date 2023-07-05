. "$HOME/.cargo/env"

path+=("$HOME/.local/share/bob/nvim-bin")

# opam configuration
[[ ! -r /home/zazed/.opam/opam-init/init.zsh ]] || source /home/zazed/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

export PATH
