---@type vim.lsp.Config
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyrightconfig.json',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  settings = {
    -- Resolve the interpreter from a project-local .venv (relative to the LSP
    -- root dir). Standard layout for Peru python packages (e.g. ARSensing*).
    python = {
      pythonPath = '.venv/bin/python',
    },
    basedpyright = {
      analysis = {
        -- basedpyright defaults to 'recommended' (stricter than pyright strict);
        -- 'standard' matches plain pyright and avoids drowning projects that
        -- gate on mypy/ruff/pylint in reportAny/reportExplicitAny noise.
        typeCheckingMode = 'standard',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          genericTypes = true,
        },
      },
    },
  },
}
