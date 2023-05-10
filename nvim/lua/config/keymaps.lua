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

-- view centering
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- better pasting (greatest keymap ever)
keymap.set("n", "<leader>p", '"_dP')

-- paste over selection without yanking
keymap.set("x", "p", "P")

-- using delete without yank
keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })

-- lsp remaps
keymap.set("n", "<leader>ra", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })

-- toggleterm
local opts = { buffer = 0 }
keymap.set("n", "<M-h>", "<cmd>ToggleTerm dir=<CR>")
keymap.set("t", "<M-h>", "<cmd>ToggleTerm<CR>")
keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
keymap.set("t", "jk", [[<C-\><C-n>]], opts)
keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)

-- Move line in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- extra dumb shit
keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>")

-- rebinding Ctrl-A to increment
keymap.set("n", "<C-a>", "<Nop>", { noremap = true })
keymap.set("n", "<C-a>", "<C-a>", { noremap = true })
