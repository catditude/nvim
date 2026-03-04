-- File explorer that lets you edit your filesystem like a buffer
return {
  "stevearc/oil.nvim",
  dependencies = { "echasnovski/mini.icons" },
  lazy = false, -- Recommended: don't lazy load (tricky to get right)
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
  },
  opts = {
    win_options = {
      signcolumn = "yes:2",
    },
    view_options = {
      show_hidden = true,
    },
  },
}
