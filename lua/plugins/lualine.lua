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
      lualine_b = {
        "branch",
        {
          function()
            local signs = vim.b.gitsigns_status_dict
            if not signs then return "" end
            local dirty = (signs.changed or 0) + (signs.added or 0) + (signs.removed or 0) > 0
            return dirty and "*" or ""
          end,
          color = { fg = "#e8b75f" },
          padding = { left = 0, right = 1 },
        },
        {
          function()
            local signs = vim.b.gitsigns_head and vim.b.gitsigns_status_dict
            if not signs then return "" end
            local parts = {}
            if (signs.ahead or 0) > 0 then table.insert(parts, "↑" .. signs.ahead) end
            if (signs.behind or 0) > 0 then table.insert(parts, "↓" .. signs.behind) end
            return table.concat(parts, " ")
          end,
          color = { fg = "#00bcd4" },
          padding = { left = 0, right = 1 },
        },
        "diff",
        "diagnostics",
      },
      lualine_c = {
        {
          function()
            return vim.fn.pathshorten(vim.fn.expand("%:~:h"))
          end,
          icon = "",
          color = { fg = "#afafd7" },
        },
        { "filename", icon = "󰄛", color = { fg = "#F0C4C8" } },
      },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
