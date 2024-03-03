-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- disable auto comment when insert new line after comment
vim.api.nvim_create_autocmd("bufEnter", {
  group = vim.api.nvim_create_augroup("FormatOptions", {}),
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o", "p" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "norg",
  callback = function()
    vim.opt.foldmethod = "marker"
  end,
})

-- only enter command history if ctrl-f is pressed
local function escape(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

vim.keymap.set("c", "<c-f>", function()
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

vim.api.nvim_exec(
  [[
  augroup MyGitSignsHighlights
    autocmd!
    autocmd BufEnter * highlight GitSignsAdd guibg=NONE
    autocmd BufEnter * highlight GitSignsAddNr guibg=NONE
    autocmd BufEnter * highlight GitSignsAddLn guibg=NONE
    autocmd BufEnter * highlight GitSignsChange guibg=NONE
    autocmd BufEnter * highlight GitSignsRemove guibg=NONE
    autocmd BufEnter * highlight GitSignsDelete guibg=NONE
  augroup END
]],
  true
)

vim.cmd([[
augroup NeoTreeConfig
    autocmd!
    autocmd FileType neotree setlocal bufhidden=hide
augroup END
]])

vim.cmd([[
  augroup coq_filetype
    autocmd!
    autocmd BufNewFile,BufRead *.v set filetype=coq
  augroup END
]])

-- fix for a fucking stupid terminal writing bug
-- vim.cmd('command! -nargs=0 Z w | qa')
-- vim.cmd('cabbrev wqa Z')
