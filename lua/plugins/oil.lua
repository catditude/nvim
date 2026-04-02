-- File explorer that lets you edit your filesystem like a buffer
return {
  "stevearc/oil.nvim",
  dependencies = { "echasnovski/mini.icons" },
  lazy = false,
  init = function()
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  end,
  opts = {
    keymaps = {
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["Y"] = {
        desc = "Copy absolute file path to clipboard",
        callback = function()
          local entry = require("oil").get_cursor_entry()
          local dir = require("oil").get_current_dir()
          if not entry or not dir then return end
          local full_path = dir .. entry.name
          vim.fn.setreg("+", full_path)
          vim.notify(full_path, vim.log.levels.INFO)
        end,
      },
    },
    win_options = {
      signcolumn = "yes:2",
    },
    view_options = {
      show_hidden = true,
    },
  },
}
