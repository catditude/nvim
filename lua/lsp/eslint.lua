-- Adapted from nvim-lspconfig's lsp/eslint.lua. The server reports nothing unless
-- these settings are sent (validate = 'on' in particular) and it gets a
-- workspaceFolder, and it waits on the eslint/* requests handled below.
local config_files = {
  '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json',
  'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs',
  'eslint.config.ts', 'eslint.config.mts', 'eslint.config.cts',
}

---@type vim.lsp.Config
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  -- Start only under an eslint config; elsewhere the server would warn that it
  -- can't find the eslint library. Root is the package (lock file), else .git.
  root_dir = function(bufnr, on_dir)
    if not vim.fs.root(bufnr, config_files) then return end
    on_dir(vim.fs.root(bufnr, { { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lock', 'bun.lockb' }, '.git' })
      or vim.fn.getcwd())
  end,
  settings = {
    validate = 'on',
    useESLintClass = false,
    experimental = {},
    codeActionOnSave = { enable = false, mode = 'all' },
    format = true,
    quiet = false,
    onIgnoredFiles = 'off',
    rulesCustomizations = {},
    run = 'onType',
    problems = { shortenToSingleLine = false },
    nodePath = '',
    workingDirectory = { mode = 'auto' },
    codeAction = {
      disableRuleComment = { enable = true, location = 'separateLine' },
      showDocumentation = { enable = true },
    },
  },
  before_init = function(_, config)
    if config.root_dir then
      config.settings.workspaceFolder = {
        uri = vim.uri_from_fname(config.root_dir),
        name = vim.fn.fnamemodify(config.root_dir, ':t'),
      }
    end
  end,
  handlers = {
    ['eslint/openDoc'] = function(_, result)
      if result then vim.ui.open(result.url) end
      return {}
    end,
    ['eslint/confirmESLintExecution'] = function(_, result)
      if result then return 4 end -- approved
    end,
    ['eslint/probeFailed'] = function()
      vim.notify('[eslint] probe failed', vim.log.levels.WARN)
      return {}
    end,
    ['eslint/noLibrary'] = function()
      vim.notify('[eslint] eslint library not found (run npm install / brazil-build?)', vim.log.levels.WARN)
      return {}
    end,
  },
}
