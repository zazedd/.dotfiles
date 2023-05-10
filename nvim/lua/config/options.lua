-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.undofile = true

opt.updatetime = 300

vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.g.neotree_highlight_file = { ctermfg = "#fff" }

vim.cmd("highlight Normal guibg=#101B1F")
