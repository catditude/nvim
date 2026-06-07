vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 999
vim.opt.updatetime = 300
vim.opt.autoread = true
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:200" })
vim.cmd.colorscheme("1989")

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set({"n", "v"}, "y", '"+y')
vim.keymap.set({"n", "v"}, "<leader>p", '"+p')

vim.keymap.set("v", "Y", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local path = vim.api.nvim_buf_get_name(0)
  local loc = start_line == end_line
    and path .. ":" .. start_line
    or path .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", loc)
  vim.notify("Copied: " .. loc)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Copy file path with line range" })

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>")
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>")

local function listed_bufs()
  return vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
end

vim.keymap.set("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(listed_bufs()) do
    if buf ~= cur then vim.api.nvim_buf_delete(buf, {}) end
  end
end, { desc = "Close other buffers" })

vim.keymap.set("n", "<leader>br", function()
  local cur = vim.api.nvim_get_current_buf()
  local past_current = false
  for _, buf in ipairs(listed_bufs()) do
    if buf == cur then past_current = true
    elseif past_current then vim.api.nvim_buf_delete(buf, {}) end
  end
end, { desc = "Close buffers to the right" })

vim.keymap.set("n", "<leader>bl", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(listed_bufs()) do
    if buf == cur then break end
    vim.api.nvim_buf_delete(buf, {})
  end
end, { desc = "Close buffers to the left" })

vim.keymap.set("n", "<leader>ba", "<cmd>%bdelete<CR>", { desc = "Close all buffers" })

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, "<cmd>LualineBuffersJump " .. i .. "<CR>")
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

require("lazy_init")
require("lsp_setup")
require("file_watcher")
require("git_ahead_behind")

