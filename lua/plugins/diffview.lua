-- Side-by-side diff viewer with syntax highlighting and file history
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
  opts = {
    keymaps = {
      view = { q = "<cmd>DiffviewClose<cr>" },
      file_panel = { q = "<cmd>DiffviewClose<cr>" },
      file_history_panel = { q = "<cmd>DiffviewClose<cr>" },
    },
  },
}
