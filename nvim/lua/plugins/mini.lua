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
}
