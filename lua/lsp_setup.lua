vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.config('rust_analyzer', require('lsp.rust_analyzer'))
vim.lsp.enable('rust_analyzer')
vim.lsp.config('basedpyright', require('lsp.basedpyright'))
vim.lsp.enable('basedpyright')
vim.lsp.config('ruff', require('lsp.ruff'))
vim.lsp.enable('ruff')
vim.lsp.config('lua_ls', require('lsp.lua_ls'))
vim.lsp.enable('lua_ls')
vim.lsp.config('jsonls', require('lsp.jsonls'))
vim.lsp.enable('jsonls')
vim.lsp.config('vtsls', require('lsp.vtsls'))
vim.lsp.enable('vtsls')
vim.lsp.config('eslint', require('lsp.eslint'))
vim.lsp.enable('eslint')
vim.lsp.inlay_hint.enable(true)

vim.diagnostic.config({
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = true,
  virtual_text = false,
})

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { desc = 'Find references' })
vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous diagnostic' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format({ async = true }) end, { desc = 'Format file' })
vim.keymap.set('n', '<leader>ci', function() require('telescope.builtin').lsp_incoming_calls() end, { desc = 'Incoming calls' })
vim.keymap.set('n', '<leader>co', function() require('telescope.builtin').lsp_outgoing_calls() end, { desc = 'Outgoing calls' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_on_attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Disable hover from Ruff (defer to basedpyright)
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end

    -- Highlight symbol under cursor on CursorHold
    if client:supports_method('textDocument/documentHighlight') then
      local group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd('CursorHold', {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

