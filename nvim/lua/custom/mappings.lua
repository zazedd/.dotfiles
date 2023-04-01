---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>wtf"] = { "<cmd>CellularAutomaton make_it_rain<CR>", "make it fucking rain" },
    ["<leader>rb"] = { "<cmd>FSToggle<CR>", "bionic reading" },
    ["<leader>s"] = { "<cmd>SidebarNvimOpen<CR>", "open sidebar" },
    ["<TAB>"] = { "<cmd>bnext<CR>", "goto next buffer" },
    ["<S-Tab>"] = { "<cmd>bprevious<CR>", "goto prev buffer" },
    ["<leader>x"] = { "<cmd>BufDel<CR>", "close buffer" },
    ["<leader>fb"] = { "<cmd>Telescope file_browser<CR>", "file browser" },
    ["<leader>pp"] = { "<cmd>Telescope projects<CR>", "projects" },
    ["w"] = {
      function()
        require("spider").motion "w"
      end,
      "Spider-w",
    },
    ["e"] = {
      function()
        require("spider").motion "e"
      end,
      "Spider-e",
    },
    ["b"] = {
      function()
        require("spider").motion "b"
      end,
      "Spider-b",
    },
    ["ge"] = {
      function()
        require("spider").motion "ge"
      end,
      "Spider-ge",
    },
  },
}

-- more keybinds!

return M
