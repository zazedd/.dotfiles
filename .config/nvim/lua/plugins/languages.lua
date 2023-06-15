return {

  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = "MarkdownPreview",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  {
    "Olical/conjure",
  },
}
