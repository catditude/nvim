-- Fuzzy finder for files, grep, buffers, and more
return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols (global)" },
  },
  opts = {},
}
