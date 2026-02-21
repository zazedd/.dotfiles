return {
  { "mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {},
        nixd = {},
        luals = {},
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "ocaml",

        "bash",
        "html",
        "lua",
        "markdown",
        "markdown_inline",
        "python",

        "query",
        "regex",
        "json",
        "yaml",

        "vim",
      },
    },
  },
}
