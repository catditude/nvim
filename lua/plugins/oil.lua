-- File explorer that lets you edit your filesystem like a buffer
return {
  "stevearc/oil.nvim",
  dependencies = { "echasnovski/mini.icons" },
  lazy = false,
  init = function()
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  end,
  opts = {
    win_options = {
      signcolumn = "yes:2",
    },
    view_options = {
      show_hidden = true,
    },
  },
}
