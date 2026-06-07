-- Statusline showing mode, branch, diagnostics, breadcrumbs, and cursor position
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "SmiteshP/nvim-navic" },
  event = "VeryLazy",
  config = function(_, opts)
    require("lualine").setup(opts)
    -- Lualine's setup() forces showtabline=2 and laststatus=3. Since lualine
    -- loads on VeryLazy (after the dashboard is already open), this overrides
    -- the values set by the SnacksDashboardOpened autocmd in snacks.lua.
    -- Re-apply here so the bars stay hidden on startup. Do NOT remove this —
    -- the snacks autocmd alone is not enough due to this load-order race.
    if vim.bo.filetype == "snacks_dashboard" then
      vim.o.showtabline = 0
      vim.o.laststatus = 0
    end
  end,
  opts = {
    options = {
      theme = "1989",
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
            local ahead = vim.g._git_ahead or 0
            local behind = vim.g._git_behind or 0
            local parts = {}
            if ahead > 0 then table.insert(parts, "↑" .. ahead) end
            if behind > 0 then table.insert(parts, "↓" .. behind) end
            return table.concat(parts, " ")
          end,
          cond = function()
            return (vim.g._git_ahead or 0) > 0 or (vim.g._git_behind or 0) > 0
          end,
          color = { fg = "#A2CFFE" },
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
        {
          function() return require("nvim-navic").get_location() end,
          cond = function() return require("nvim-navic").is_available() end,
          color = { fg = "#FFFFFF", bg = "#444444" },
        },
      },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    tabline = {
      lualine_a = {
        {
          "buffers",
          icons_enabled = true,
          mode = 2,
          fmt = function(name, context)
            local path = vim.api.nvim_buf_get_name(context.bufnr)
            local crate = path:match("/crates/([^/]+)/")
            if crate then
              return crate .. "/" .. vim.fn.fnamemodify(path, ":t")
            end
            return name
          end,
        },
      },
      lualine_z = { "tabs" },
    },
  },
}
