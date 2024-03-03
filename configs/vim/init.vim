"" General
set number
set history=1000
set nocompatible
set modelines=0
set encoding=utf-8
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set cursorline
set ttyfast
set nowrap
set ruler
set backspace=indent,eol,start
set laststatus=2
set clipboard=autoselect

" Dir stuff
set nobackup
set nowritebackup
set noswapfile
set backupdir=~/.config/vim/backups
set directory=~/.config/vim/swap

" Relative line numbers for easy movement
set relativenumber
set rnu

"" Whitespace rules
set tabstop=8
set shiftwidth=2
set softtabstop=2
set expandtab

"" Searching
set incsearch
set gdefault

"" Local keys and such
let mapleader=","
let maplocalleader=" "

"" Change cursor on mode
:autocmd InsertEnter * set cul
:autocmd InsertLeave * set nocul

"" File-type highlighting and configuration
syntax on
filetype on
filetype plugin on
filetype indent on

"" Paste from clipboard
nnoremap <Leader>, "+gP

"" Copy from clipboard
xnoremap <Leader>. "+y

"" Move cursor by display lines when wrapping
nnoremap j gj
nnoremap k gk

"" Map leader-q to quit out of window
nnoremap <leader>q :q<cr>

"" Move around split
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"" Easier to yank entire line
nnoremap Y y$

"" Like a boss, sudo AFTER opening the file to write
cmap w!! w !sudo tee % >/dev/null
'';
