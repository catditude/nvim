-- nowrap: render-markdown draws tables correctly only on unwrapped lines.
-- Wide tables: a wrapped copy pops up over the table while the cursor is in it;
-- <leader>mt opens it focused (to scroll a tall one).
vim.opt_local.wrap = false
vim.opt_local.relativenumber = false
vim.opt_local.colorcolumn = ""
vim.keymap.set("n", "<leader>mt", function() require("md_table").open() end,
  { buffer = true, desc = "Table under cursor in float (wrapped cells)" })
require("md_table").attach(0)
