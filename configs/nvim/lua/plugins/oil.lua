return {
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["<ESC>"] = { "actions.close", mode = "n" },
        ["<leader>e"] = { "actions.close", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
      },
      columns = {
        "icon",
      },
      view_options = {
        show_hidden = true,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
