-- Fuzzy finder for files, grep, buffers, and more

-- Map all LSP SymbolKind values to existing syntax highlight groups
local symbol_highlights = {
  Class = "Type",
  Constant = "Constant",
  Constructor = "Function",
  Enum = "Type",
  EnumMember = "Constant",
  Event = "Special",
  Field = "TelescopeResultsField",
  Function = "Function",
  Interface = "Type",
  Key = "Identifier",
  Method = "Function",
  Module = "Keyword",
  Namespace = "Keyword",
  Object = "Type",
  Operator = "Operator",
  Package = "Keyword",
  Property = "TelescopeResultsField",
  String = "String",
  Struct = "Type",
  TypeParameter = "Type",
  Variable = "TelescopeResultsVariable",
}

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
    {
      "<leader>fs",
      function() require("telescope.builtin").lsp_document_symbols({ symbol_highlights = symbol_highlights }) end,
      desc = "Document symbols",
    },
    {
      "<leader>fo",
      function()
        require("telescope.builtin").lsp_document_symbols({
          symbols = {
            "File", "Module", "Namespace", "Package", "Class", "Method",
            "Property", "Field", "Constructor", "Enum", "Interface",
            "Function", "Constant", "String", "Number", "Boolean",
            "Array", "Object", "Key", "Null", "EnumMember", "Struct",
            "Event", "Operator", "TypeParameter",
          },
          symbol_highlights = symbol_highlights,
        })
      end,
      desc = "Document outline (no variables)",
    },
    {
      "<leader>fS",
      function() require("telescope.builtin").lsp_dynamic_workspace_symbols({ symbol_highlights = symbol_highlights }) end,
      desc = "Workspace symbols (global)",
    },
  },
  opts = {
    defaults = {
      path_display = { "truncate" },
      -- Directory excludes (Brazil env/build, node_modules, python site-packages, etc.) are NOT
      -- set here: they live in ~/workplace/.ignore, which both rg (grep) and fd (find_files) read.
    },
  },
}
