local colors = {
  dark_gray = "#1c1c1c",
  charcoal = "#262626",
  dim_gray = "#303030",
  light_gray = "#444444",
  gray_purple = "#afafd7",
  white = "#FFFFFF",
  pink = "#f075a0",
  light_pink = "#F0C4C8",
  lavender = "#dfafff",
  light_blue = "#A2CFFE",
  mint = "#9EB294",
  light_yellow = "#ffffaf",
  orange = "#FFC067",
}

return {
  normal = {
    a = { fg = colors.dark_gray, bg = colors.light_pink, gui = "bold" },
    b = { fg = colors.white, bg = colors.dim_gray },
    c = { fg = colors.light_pink, bg = colors.light_gray },
  },
  insert = {
    a = { fg = colors.dark_gray, bg = colors.light_blue, gui = "bold" },
  },
  visual = {
    a = { fg = colors.dark_gray, bg = colors.lavender, gui = "bold" },
  },
  command = {
    a = { fg = colors.dark_gray, bg = colors.light_yellow, gui = "bold" },
  },
  replace = {
    a = { fg = colors.dark_gray, bg = colors.orange, gui = "bold" },
  },
  inactive = {
    a = { fg = colors.gray_purple, bg = colors.charcoal },
    b = { fg = colors.gray_purple, bg = colors.charcoal },
    c = { fg = colors.gray_purple, bg = colors.charcoal },
  },
}
