-- Statusline showing mode, branch, diagnostics, file info, and cursor position
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "seoul256",
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          function()
            return vim.fn.expand("%:.:h")
          end,
          icon = " ",
          color = { fg = "#afafd7" },
        },
        { "filename", color = { fg = "#F0C4C8" } },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
