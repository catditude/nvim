vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.cmd.colorscheme("1989")

require("lazy_init")
require("lsp_setup")
require("file_watcher")

