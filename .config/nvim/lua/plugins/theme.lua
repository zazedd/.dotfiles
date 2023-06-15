return {
  -- test
  -- {
  --   "RRethy/nvim-base16",
  --   config = function()
  --     require("base16-colorscheme").setup({
  --       base00 = "#080a0a",
  --       base01 = "#0C171B",
  --       base02 = "#101B1F",
  --       base03 = "#495154",
  --       base04 = "#4b646e",
  --       base05 = "#D9D7D6",
  --       base06 = "#E3E1E0",
  --       base07 = "#EDEBEA",
  --       base08 = "#8a9099",
  --       base09 = "#eb8d1a",
  --       base0A = "#84a0c6",
  --       base0B = "#89b8c2",
  --       base0C = "#b4be82",
  --       base0D = "#4278e3",
  --       base0E = "#84a0c6",
  --       base0F = "#7aa5e6",
  --     })
  --   end,
  -- },
  -- {
  --   "marko-cerovac/material.nvim",
  -- },

  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
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
          c.bg_sidebar = "#15191f"
          c.StatusLine = { bg = "#1c1c1c" }
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = require("lazyvim.config").icons
      local Util = require("lazyvim.util")
      local custom_theme = require("lualine.themes.tokyonight")

      custom_theme.normal.c.bg = "#15191f"
      custom_theme.visual.b.fg = "#eb8d1a"
      custom_theme.visual.a.bg = "#eb8d1a"
      custom_theme.command.a.bg = "#8a9099"
      custom_theme.command.b.fg = "#8a9099"

      return {
        options = {
          theme = custom_theme,
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
            -- stylua: ignore
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
            },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = Util.fg("Statement"),
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = Util.fg("Constant"),
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = Util.fg("Debug"),
            },
            { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = Util.fg("Special") },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
            { "lsp", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return "  " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
      })
    end,
  },
}
