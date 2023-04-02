local M = {}

M.base_30 = {
  white = "#D9D7D6",
  darker_black = "#000a0e",
  black = "#000000", --  nvim bg
  black2 = "#0d181c",
  one_bg = "#131e22",
  one_bg2 = "#1c272b",
  one_bg3 = "#242f33",
  grey = "#313c40",
  grey_fg = "#3b464a",
  grey_fg2 = "#455054",
  light_grey = "#4f5a5e",
  red = "#DF5B61",
  baby_pink = "#EE6A70",
  pink = "#F16269",
  line = "#222d31", -- for lines like vertsplit
  green = "#78B892",
  vibrant_green = "#67AFC1",
  nord_blue = "#5A84BC",
  blue = "#6791C9",
  yellow = "#ecd28b",
  sun = "#f6dc95",
  purple = "#C488EC",
  dark_purple = "#BC83E3",
  teal = "#7ACFE4",
  orange = "#E89982",
  cyan = "#67AFC1",
  statusline_bg = "#0A1519",
  lightbg = "#1a2529",
  pmenu_bg = "#78B892",
  folder_bg = "#6791C9",
}

M.base_16 = {
  base00 = "#061115",
  base01 = "#0C171B",
  base02 = "#101B1F",
  base03 = "#192428",
  base04 = "#212C30",
  base05 = "#D9D7D6",
  base06 = "#E3E1E0",
  base07 = "#EDEBEA",
  base08 = "#8a9099", -- modules, try catches
  base09 = "#eb8d1a", -- ints and bools
  base0A = "#84a0c6", -- let // public static
  base0B = "#89b8c2", -- strings
  base0C = "#b4be82", -- special chars
  base0D = "#4278e3", -- functions
  base0E = "#84a0c6",
  base0F = "#7aa5e6", -- |, ->, ., (), and such
}

M.type = "dark"

M = require("base46").override_theme(M, "iceberg")

return M
