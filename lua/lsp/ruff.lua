---@type vim.lsp.Config
return {
  -- Prefer the project venv's ruff (pinned by the team, e.g. via
  -- amzn_ars_meta_config) over whatever is on PATH. Ruff is a self-contained
  -- binary: the server IS the linter, so the binary chosen decides the
  -- rule set/version. Falls back to PATH if no root .venv exists.
  cmd = function(dispatchers, config)
    local bin = 'ruff'
    local root = config.root_dir
    if root then
      local venv_ruff = root .. '/.venv/bin/ruff'
      if vim.uv.fs_stat(venv_ruff) then
        bin = venv_ruff
      end
    end
    vim.g.ruff_lsp_bin = bin -- introspection: :echo g:ruff_lsp_bin
    return vim.lsp.rpc.start({ bin, 'server' }, dispatchers)
  end,
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'ruff.toml',
    '.ruff.toml',
    '.git',
  },
}
