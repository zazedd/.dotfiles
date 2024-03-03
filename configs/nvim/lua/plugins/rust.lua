return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = { "rust" },
  },

  {
    "saecki/crates.nvim",
    tag = "stable",
    ft = { "rust" },
    config = function()
      require("crates").setup()
    end,
  },
}
