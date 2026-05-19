---@type vim.lsp.Config
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      validate = { enable = true },
      schemas = {
        {
          fileMatch = {
            vim.fn.expand('~/.claude/settings.json'),
            vim.fn.expand('~/.claude/settings.local.json'),
            '**/.claude/settings.json',
            '**/.claude/settings.local.json',
          },
          url = 'https://json.schemastore.org/claude-code-settings.json',
        },
      },
    },
  },
}
