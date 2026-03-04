-- Side-by-side diff viewer with syntax highlighting and file history
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
  opts = {
    hooks = {
      diff_buf_read = function(bufnr)
        -- Trigger BufReadPost so treesitter-context recognizes diff buffers
        vim.api.nvim_exec_autocmds("BufReadPost", { buffer = bufnr })
      end,
    },
    keymaps = {
      view = { q = "<cmd>DiffviewClose<cr>" },
      file_panel = { q = "<cmd>DiffviewClose<cr>" },
      file_history_panel = { q = "<cmd>DiffviewClose<cr>" },
    },
  },
}
