-- Popup keybinding hints — press <leader> and wait to see available mappings
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git / review" },
      { "<leader>h", group = "hunks" },
    },
  },
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps",
    },
  },
}
