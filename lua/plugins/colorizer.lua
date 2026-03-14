-- Render hex color codes with their actual color
return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    "*",
    lua = { names = false },
  },
}
