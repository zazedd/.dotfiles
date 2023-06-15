return {
  {
    "echasnovski/mini.indentscope",
    enabled = false,
  },

  {
    "echasnovski/mini.comment",
    enabled = false,
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    cmd = "Telescope file_browser",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      config = function()
        require("telescope").load_extension("file_browser")
      end,
    },
  },

  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
  },

  {
    "jubnzv/virtual-types.nvim",
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local dashboard = require("alpha.themes.dashboard")
      local newlogo = [[
     _____________________________________________/\/\____/\/\______________________________________/\/\_________________________________________________________________
    _____________________________________________/\/\/\__/\/\____/\/\/\______/\/\/\____/\/\__/\/\__________/\/\/\__/\/\_________________________________________________
   _____________________________________________/\/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\__/\/\__/\/\__/\/\____/\/\/\/\/\/\/\_______________________________________________
  _____________________________________________/\/\__/\/\/\__/\/\________/\/\__/\/\____/\/\/\____/\/\____/\/\__/\__/\/\_______________________________________________
 _____________________________________________/\/\____/\/\____/\/\/\/\____/\/\/\________/\______/\/\/\__/\/\______/\/\_______________________________________________
____________________________________________________________________________________________________________________________________________________________________
   ]]
      dashboard.section.header.val = vim.split(newlogo, "\n")
    end,
  },
}
