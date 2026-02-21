-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.api.nvim_create_autocmd("bufEnter", {
  group = vim.api.nvim_create_augroup("FormatOptions", {}),
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o", "p" })
  end,
})

-- only enter command history if ctrl-f is pressed
local function escape(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end
vim.keymap.set("n", "<c-f>", function()
  vim.g.requested_cmdwin = true
  vim.api.nvim_feedkeys(escape("<c-f>"), "n", false)
end)

vim.api.nvim_create_autocmd("cmdwinenter", {
  group = vim.api.nvim_create_augroup("cwe", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.g.requested_cmdwin then
      vim.g.requested_cmdwin = nil
    else
      vim.api.nvim_feedkeys(escape(":q<cr>:"), "m", false)
    end
  end,
})

vim.cmd([[
  augroup coq_filetype
    autocmd!
    autocmd BufNewFile,BufRead *.v set filetype=coq
  augroup END
]])
