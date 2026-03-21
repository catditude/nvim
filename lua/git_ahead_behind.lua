-- Periodically fetches git ahead/behind counts and exposes them as vim.g globals
local function update()
  vim.system(
    { "git", "rev-list", "--left-right", "--count", "HEAD...@{upstream}" },
    { text = true },
    function(result)
      if result.code == 0 and result.stdout then
        local ahead, behind = result.stdout:match("(%d+)%s+(%d+)")
        vim.schedule(function()
          vim.g._git_ahead = tonumber(ahead) or 0
          vim.g._git_behind = tonumber(behind) or 0
        end)
      else
        vim.schedule(function()
          vim.g._git_ahead = 0
          vim.g._git_behind = 0
        end)
      end
    end
  )
end

update()

local timer = vim.uv.new_timer()
timer:start(30000, 30000, vim.schedule_wrap(update))

vim.api.nvim_create_autocmd({ "FocusGained", "BufWritePost" }, {
  callback = update,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    timer:stop()
    timer:close()
  end,
})
