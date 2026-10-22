-- Tables are covered by floats with wrapped cells (lua/md_table.lua), so prose
-- can wrap without breaking table drawing. <leader>mt opens the table focused.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.relativenumber = false
vim.opt_local.colorcolumn = ""
vim.keymap.set("n", "<leader>mt", function() require("md_table").open() end,
  { buffer = true, desc = "Table under cursor in float (wrapped cells)" })
-- File buffers only: LSP hover docs are markdown too.
if vim.bo.buftype == "" then
  require("md_table").attach(0)
  require("md_zen").attach(0)
end
