-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
local map = vim.keymap.set
local del = vim.keymap.del

del("n", "<leader>l")
del("n", "<C-f>")
del("i", "<C-f>")

map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Oil", remap = true })
map("n", "<leader>e", Util.pick("files"), { desc = "Files", remap = true })

map("n", "<C-d>", "<C-d>zz", { desc = "Center on Ctrl-d", remap = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Center on Ctrl-u", remap = true })

map("n", "<C-b>", ':lua require("specs").show_specs()', { noremap = true, silent = true })

map("n", "<leader>xc", function()
  Util.news.changelog()
end, { desc = "LazyVim Changelog" })
