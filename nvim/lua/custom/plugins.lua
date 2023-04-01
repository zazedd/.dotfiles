local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- overrde plugin configs
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    event = "InsertEnter",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  {
    "ggandor/leap.nvim",
    event = "InsertEnter",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  {
    "ahmedkhalf/project.nvim",
    cmd = "Telescope projects",
    config = function()
      require("project_nvim").setup {
        show_hidden = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = false,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
      }
    end,
  },

  {
    "sidebar-nvim/sidebar.nvim",
    cmd = { "SidebarNvimToggle", "SidebarNvimOpen" },
    config = function()
      require "custom.configs.sidebar"
    end,
  },

  {
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup()
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    event = "InsertEnter",
    config = function()
      require "custom.configs.scrollbar"
    end,
  },

  {
    "ojroques/nvim-bufdel",
    cmd = "BufDel",
  },

  {
    "chrisgrieser/nvim-spider",
    event = "InsertEnter",
  },

  {
    "turbio/bracey.vim",
    cmd = "Bracey",
  },

  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },

  {
    "nullchilly/fsread.nvim",
    cmd = "FSToggle",
  },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- Uncomment if you want to re-enable which-key
  -- {
  --   "folke/which-key.nvim",
  --   enabled = true,
  -- },
}

return plugins
