-- Popup keybinding hints — press <leader> and wait to see available mappings
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
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
