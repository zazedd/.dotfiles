-- Disabled plugins
-- In case we want to re-enable them in the future.

--    Sections:
--       -> autopairs
--       -> stay-centered
--       -> ranger.vim
--       -> vin-matchups
--       -> guess-indent

return {
  --  [autopairs] auto closes (), "", '', [], {}
  --  https://github.com/windwp/nvim-autopairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },

  -- -- stay-centered.nvim [cursor centered]
  -- -- https://github.com/arnamak/stay-centered.nvim
  --
  -- NOTE: use scrolloff = 1000 instead of this plugin
  --       it causes problems with other plugins like mini.animate.
  -- {
  --   "arnamak/stay-centered.nvim",
  --   lazy = false,
  --   opts = {
  --     skip_filetypes = {
  --       "ranger",
  --       "rnvimr",
  --       "neotree",
  --       "NvimTree",
  --       "neo-tree",
  --       "neotree-popup",
  --       "spectre_panel",
  --       "help",
  --       "startify",
  --       "aerial",
  --       "aerial-nav",
  --       "alpha",
  --       "dashboard",
  --       "lazy",
  --       "neogitstatus",
  --       "Trouble",
  --     },
  --   },
  -- },

  -- [ranger] file browser (fork with mouse scroll support)
  -- https://github.com/Zeioth/ranger.vim
  -- {
  --   -- This one is a backup ranger in case rnvimr breaks for some reason.
  --   -- It supports invoking terminals from inside ranger, which Rnvimr doesn't atm.
  --   "zeioth/ranger.vim",
  --   dependencies = { "rbgrouleff/bclose.vim" },
  --   cmd = { "Ranger" },
  --   init = function() -- For this plugin has to be init
  --     vim.g.ranger_terminal = "foot"
  --     vim.g.ranger_command_override = 'LC_ALL=es_ES.UTF8 TERMCMD="foot -a "scratchpad"" ranger'
  --     vim.g.ranger_map_keys = 0
  --   end,
  -- },
}
