require("scrollbar").setup {
  handlers = {
    cursor = true,
    diagnostic = true,
    gitsigns = false, -- Requires gitsigns
    handle = true,
    search = false, -- Requires hlslens
  },
  excluded_filetypes = {
    "prompt",
    "TelescopePrompt",
    "noice",
    "NvimTree",
    "neo-tree",
    "Nvdash",
    "SidebarNvim",
  },
}
