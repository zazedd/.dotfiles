require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  local alpha = function()
    return string.format("%x", math.floor((255 * vim.g.transparency) or 0.8))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_transparency = 0.8
  vim.g.transparency = 0.9
  vim.g.neovide_background_color = alpha()
  vim.g.neovide_floating_blur_amount_x = 10
  vim.g.neovide_floating_blur_amount_y = 10

  vim.o.guifont = "JetBrainsMono Nerd Font"
end

vim.opt.rtp:prepend(lazypath)
require "plugins"

dofile(vim.g.base46_cache .. "defaults")

vim.o.autochdir = true
vim.g.nvim_tree_respect_buf_cwd = 1
vim.wo.relativenumber = true

-- bracey.vim
local enable_providers = {
  "python3_provider",
}

for _, plugin in pairs(enable_providers) do
  vim.g["loaded_" .. plugin] = nil
  vim.cmd("runtime " .. plugin)
end

vim.g["bracey_server_allow_remote_connections"] = 1

-- colors
vim.cmd "hi Normal guibg=#000000"
vim.g.flow_strength = 0.5 -- low: 0.3, middle: 0.5, high: 0.7 (default)
vim.api.nvim_set_hl(0, "FSPrefix", { fg = "#cdd6f4" })
vim.api.nvim_set_hl(0, "FSSuffix", { fg = "#6C7086" })

require("telescope").load_extension "projects"
