-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.loaded_coqtail = 1
vim.g["coqtail#supported"] = 0

vim.api.nvim_command("highlight NeoTreeNormalNC guibg=#111111")
vim.api.nvim_command("highlight NeoTreeNormal guibg=#111111")

local ui = require("lazyvim.plugins.ui")

local function get_num_wraps()
  -- Calculate the actual buffer width, accounting for splits, number columns, and other padding
  local wrapped_lines = vim.api.nvim_win_call(0, function()
    local winid = vim.api.nvim_get_current_win()

    -- get the width of the buffer
    local winwidth = vim.api.nvim_win_get_width(winid)
    local numberwidth = vim.wo.number and vim.wo.numberwidth or 0
    local signwidth = vim.fn.exists("*sign_define") == 1 and vim.fn.sign_getdefined() and 2 or 0
    local foldwidth = vim.wo.foldcolumn or 0

    -- subtract the number of empty spaces in your statuscol. I have
    -- four extra spaces in mine, to enhance readability for me
    local bufferwidth = winwidth - numberwidth - signwidth - foldwidth - 4

    -- fetch the line and calculate its display width
    local line = vim.fn.getline(vim.v.lnum)
    local line_length = vim.fn.strdisplaywidth(line)

    return math.floor(line_length / bufferwidth)
  end)

  return wrapped_lines
end

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
  elseif vim.v.virtnum < 0 then
    components[2] = "-"
  -- softwrapping
  elseif vim.v.virtnum > 0 and is_relnum then
    local num_wraps = get_num_wraps()

    if vim.v.virtnum == num_wraps then
      components[2] = "└"
    else
      components[2] = "├"
    end

    components[2] = "%=" .. components[2] .. " %#IndentBlankLineChar#" -- right align
  end

  vim.o.foldcolumn = "1"

  return table.concat(components, "")
end

ui.statuscolumn = customstatuscolumn
