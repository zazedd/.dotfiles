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
          -- BlinkCmpMenuBorder = { bg = colors.waveBlue2, fg = colors.waveBlue2 },
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
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "base16",
        component_separators = { left = "│ ", right = " │" },
        section_separators = { left = " ", right = " " },
        globalstatus = true,
        refresh = { statusline = 100, },
      },
    },
  }
}
