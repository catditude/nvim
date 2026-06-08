return {
  "stevearc/aerial.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle outline" },
    { "{", "<cmd>AerialPrev<CR>", desc = "Previous symbol" },
    { "}", "<cmd>AerialNext<CR>", desc = "Next symbol" },
  },
  opts = {
    backends = { "lsp", "treesitter" },
    layout = {
      min_width = 30,
      default_direction = "right",
    },
  },
}
