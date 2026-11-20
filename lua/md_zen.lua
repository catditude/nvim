-- On markdown files, let `q` close snacks.zen (opened with <leader>z).
local M = {}

local function in_zen(win)
  local z = Snacks.zen.win
  return z ~= nil and z:valid() and z.win == win
end

function M.attach(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  -- Expr map: Snacks.zen() can't run under the mapping's textlock, so schedule it.
  vim.keymap.set("n", "q", function()
    if not in_zen(vim.api.nvim_get_current_win()) then return "q" end
    vim.schedule(function() Snacks.zen() end)
    return ""
  end, { buffer = buf, expr = true, desc = "Close zen (else record macro)" })
end

return M
