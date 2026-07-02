-- Custom diagram.nvim renderer: renders mermaid via a local Kroki HTTP server
-- instead of mmdc (Chromium), so it works on ARM where Chromium is impossible.
-- Implements the diagram.nvim renderer contract:
--   { id = <string>, render = function(source, options) -> { file_path, job_id } | nil }

local M = { id = "mermaid" }

local cache_dir = vim.fn.resolve(vim.fn.stdpath("cache") .. "/diagram-cache/mermaid")
vim.fn.mkdir(cache_dir, "p")

---@param source string  raw mermaid fence content
---@param options table  renderer options (expects options.kroki_url)
---@return table|nil
M.render = function(source, options)
  local kroki_url = (options and options.kroki_url) or "http://localhost:8000"
  local hash = vim.fn.sha256(M.id .. ":" .. kroki_url .. ":" .. source)
  local path = vim.fn.resolve(cache_dir .. "/" .. hash .. ".png")
  if vim.fn.filereadable(path) == 1 then return { file_path = path } end

  if vim.fn.executable("curl") == 0 then
    vim.notify("curl not found in PATH; cannot reach Kroki.", vim.log.levels.ERROR, { title = "diagram-kroki" })
    return nil
  end

  local tmpsource = vim.fn.tempname()
  vim.fn.writefile(vim.split(source, "\n"), tmpsource)

  -- Write to a temp path and rename on success, so a re-render firing mid-transfer
  -- never sees a partial/empty file at `path` and cache-hits it (matches diagram.nvim's
  -- built-in plantuml renderer).
  local tmppath = path .. ".new.png"
  local cmd = {
    "curl", "-sf", "-X", "POST",
    kroki_url .. "/mermaid/png",
    "--data-binary", "@" .. tmpsource,
    "-o", tmppath,
  }

  local job_id = vim.fn.jobstart(cmd, {
    on_stderr = function(_, data)
      local msg = table.concat(data or {}, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
      if msg ~= "" then
        vim.notify("Kroki render failed:\n" .. msg, vim.log.levels.ERROR, { title = "diagram-kroki" })
      end
    end,
    on_exit = function(_, code)
      -- curl -f exits non-zero (22) on HTTP >= 400
      if code == 0 then
        vim.fn.rename(tmppath, path)
      else
        pcall(vim.fn.delete, tmppath)
      end
    end,
  })
  return { file_path = path, job_id = job_id }
end

return M
