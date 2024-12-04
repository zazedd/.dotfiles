-- Status column
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
-- vim.o.statuscolumn = "%=%s%=%r %#IndentBlankLineChar# "
-- vim.o.foldcolumn = "1"

local navic = require("nvim-navic")

return {
  {
    "rebelot/kanagawa.nvim",
    event = "User LoadColorSchemes",
    opts = {
      commentStyle = { italic = true },
      transparent = false,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        local colors = colors.palette
        return {
          BlinkCmpMenu = { bg = "#111111" },
          BlinkCmpMenuBorder = { bg = colors.waveBlue2, fg = colors.waveBlue2 },
          BlinkCmpLabel = { bg = "#111111" },
          BlinkCmpMenuSelection = { fg = colors.sumiInk0, bg = colors.springBlue },
          BlinkCmpMenuBorder = { bg = "#111111" },
          BlinkCmpLabelSelection = { bg = "#111111" },
          BlinkCmpMenuMatch = { bg = colors.waveBlue1 },
        }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-dragon",
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      window = {
        position = "left",
        width = 25,
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "meuter/lualine-so-fancy.nvim",
    },
    opts = {
      options = {
        theme = "codedark",
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
        refresh = {
          statusline = 100,
        },
      },
      sections = {
        lualine_a = {
          { "fancy_mode", width = 3 },
        },
        lualine_b = {
          { "fancy_branch" },
          { "fancy_diff" },
        },
        lualine_c = {
          { "fancy_cwd", substitute_home = true },
        },
        lualine_x = {
          { "fancy_macro" },
          { "fancy_diagnostics" },
          { "fancy_searchcount" },
          { "fancy_location" },
        },
        lualine_y = {
          { "fancy_filetype", ts_icon = "" },
        },
        lualine_z = {
          { "fancy_lsp_servers" },
        },
      },
      winbar = {
        lualine_c = {
          {
            function()
              local str = navic.get_location()
              if str == "" then
                return "-"
              else
                return str
              end
            end,
            cond = function()
              return navic.is_available()
            end,
          },
        },
      },
    },
  },
}
