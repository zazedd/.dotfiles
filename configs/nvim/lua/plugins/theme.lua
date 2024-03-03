-- Status column
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
-- vim.o.statuscolumn = "%=%s%=%r %#IndentBlankLineChar# "
-- vim.o.foldcolumn = "1"

local navic = require("nvim-navic")

return {
  {
    "folke/tokyonight.nvim",
    event = "User LoadColorSchemes",
    enabled = false,
    opts = {
      plugins = { ["dashboard-nvim"] = true },
      dim_inactive = true, -- dims inactive windows
      transparent = true,

      -- Colors can be overrided
      on_highlights = function(hl, _)
        hl.Function = { fg = "#4278e3", bold = true }
        hl.SpecialChar = { fg = "#b4be82" }
        hl.Variable = { fg = "#84a0c6" }
        hl["@keyword"] = { fg = "#84a0c6" }
        hl["@keyword.function"] = { fg = "#84a0c6" }
        hl["@parameter"] = { fg = "#D9D7D6" }
        hl["@variable"] = { fg = "#D9D7D6" }
        hl["@constructor"] = { fg = "#eb8d1a" }
        hl["@conditional"] = { fg = "#7aa2f7" }
        hl["@namespace"] = { fg = "#8a9099" }
        hl["@comment"] = { fg = "#495154", italic = true }
      end,
      styles = {
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
      },
      on_colors = function(c)
        c.bg_sidebar = "#15191c"
        c.StatusLine = { bg = "#15191c" }
      end,
    },
  },

  {
    "sainnhe/gruvbox-material",
    event = "User LoadColorSchemes",
    enabled = false,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    event = "User LoadColorSchemes",
    enabled = false,
  },

  {
    "https://codeberg.org/oahlen/iceberg.nvim",
    event = "User LoadColorSchemes",
    enabled = false,
  },

  {
    "rebelot/kanagawa.nvim",
    event = "User LoadColorSchemes",
    opts = {
      commentStyle = { italic = true },
      transparent = false,
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

  {
    "rainbowhxch/beacon.nvim",
    opts = {
      size = 50,
      focus_gained = true,
    },
  },
}
