vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 999
vim.opt.updatetime = 300
vim.cmd.colorscheme("1989")

require("lazy_init")
require("lsp_setup")
require("file_watcher")

