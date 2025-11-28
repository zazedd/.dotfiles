return {

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          mason = false,
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    enabled = false,
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {},
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    enabled = false,
  },

  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", has = "definition" },
            { "lr", "<cmd>lua vim.lsp.buf.rename()<CR>", has = "rename" },
          },
        },
      },
    },

    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
}
