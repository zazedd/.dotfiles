-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.loaded_coqtail = 1
vim.g["coqtail#supported"] = 0

vim.api.nvim_command("highlight NeoTreeNormalNC guibg=#111111")
vim.api.nvim_command("highlight NeoTreeNormal guibg=#111111")

local ui = require("lazyvim.util.ui")

local function customstatuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)

  if vim.bo[buf].filetype == "neo-tree" then
    return ""
  end

  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" } -- left, middle, right

  if show_signs then
    ---@type Sign?,Sign?,Sign?
    local left, right, fold
    for _, s in ipairs(ui.get_signs(buf, vim.v.lnum)) do
      if s.name and s.name:find("GitSign") then
        right = s
      else
        left = s
      end
    end
    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      end
    end)
    -- Left: mark or non-git sign
    components[1] = ui.icon(ui.get_mark(buf, vim.v.lnum) or left)
    -- Right: fold icon or git sign (only if file)
    components[3] = is_file and ui.icon(fold or right) or ""
  end

  local is_relnum = vim.wo[win].relativenumber
  if vim.v.virtnum == 0 then
    if is_relnum and vim.v.relnum ~= 0 then
      components[2] = tostring(vim.v.relnum) -- relative lnums
    elseif vim.v.relnum == 0 then
      components[2] = tostring(vim.v.lnum) -- absolute line for the current line
    end
    components[2] = "%=" .. components[2] .. " %#IndentBlankLineChar#" -- right align
  end

  vim.o.foldcolumn = "1"

  return table.concat(components, "")
end

ui.statuscolumn = customstatuscolumn
