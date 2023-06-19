-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap

-- Telescope mappings
keymap.set(
  "n",
  "<leader>fB",
  "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true, desc = "Telescope file browser" }
)

-- tmux
keymap.set("n", "<C-h>", [[<Cmd>TmuxNavigateLeft<CR>]])
keymap.set("n", "<C-l>", [[<Cmd>TmuxNavigateRight<CR>]])
keymap.set("n", "<C-j>", [[<Cmd>TmuxNavigateDown<CR>]])
keymap.set("n", "<C-k>", [[<Cmd>TmuxNavigateUp<CR>]])

-- view centering
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- better pasting (greatest keymap ever)
keymap.set("n", "<leader>p", '"_dP', { desc = "better pasting" })

-- paste over selection without yanking
keymap.set("x", "p", "P", { desc = "paste over selection without yank" })

-- using delete without yank
keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })

-- lsp remaps
keymap.set(
  "n",
  "<leader>ra",
  "<cmd>lua vim.lsp.buf.rename()<CR>",
  { desc = "lsp rename", noremap = true, silent = true }
)

-- spectre
keymap.set("n", "<leader>S", '<cmd>lua require("spectre").open()<CR>', {
  desc = "Open Spectre",
})
keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word",
})
keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "Search current word",
})
keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "Search on current file",
})

-- Move line in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move line down in visual mode" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move line up in visual mode" })

-- better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- extra dumb shit
keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "dumb shit" })

-- undind t for some reason its the same as f
vim.api.nvim_del_keymap("n", "t")

keymap.set("n", "<leader>tl", "<cmd>require('lsp_lines').toggle()<CR>", { noremap = true, silent = true })

-- unbind quit all
vim.api.nvim_del_keymap("n", "<leader>qq")
