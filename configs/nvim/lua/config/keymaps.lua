-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
local map = vim.keymap.set
local del = vim.keymap.del

del("n", "<leader><space>")
del("n", "<leader>l")
del("n", "<C-f>")
del("i", "<C-f>")

map("n", "<C-d>", "<C-d>zz", { desc = "Center on Ctrl-d", remap = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Center on Ctrl-u", remap = true })

map("n", "<C-b>", ':lua require("specs").show_specs()', { noremap = true, silent = true })

map("n", "<leader>xc", function()
  Util.news.changelog()
end, { desc = "LazyVim Changelog" })

map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

map("n", "<leader>F", "<Cmd>Telescope git_files<CR>", { desc = "Find Git Files" })

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():append()
  local filename = vim.fn.expand("%:t")
  vim.notify("File marked: " .. filename, vim.log.levels.INFO, { title = "File Marked" })
end, { desc = "Append to marks" })
vim.keymap.set("n", "<leader>m", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Mark menu" })

-- vim.keymap.set("n", "<C-h>", function()
--   harpoon:list():select(1)
-- end)
-- vim.keymap.set("n", "<C-t>", function()
--   harpoon:list():select(2)
-- end)
-- vim.keymap.set("n", "<C-n>", function()
--   harpoon:list():select(3)
-- end)
-- vim.keymap.set("n", "<C-s>", function()
--   harpoon:list():select(4)
-- end)

vim.keymap.set("n", "<C-S-H>", function()
  harpoon:list():prev()
end, { desc = "Prev mark" })
vim.keymap.set("n", "<C-S-L>", function()
  harpoon:list():next()
end, { desc = "Next mark" })
