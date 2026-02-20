vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.config('rust_analyzer', require('lsp.rust_analyzer'))
vim.lsp.enable('rust_analyzer')
vim.lsp.config('pyright', require('lsp.pyright'))
vim.lsp.enable('pyright')
vim.lsp.inlay_hint.enable(true)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

