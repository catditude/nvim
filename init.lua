vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 999
vim.opt.updatetime = 300
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:200" })
vim.cmd.colorscheme("1989")

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set({"n", "v"}, "<leader>y", '"+y')
vim.keymap.set({"n", "v"}, "<leader>p", '"+p')

require("lazy_init")
require("lsp_setup")
require("file_watcher")

