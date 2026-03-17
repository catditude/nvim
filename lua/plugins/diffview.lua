-- Side-by-side diff viewer with syntax highlighting and file history
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen --imply-local<cr>", desc = "Diff view (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
  opts = {
    enhanced_diff_hl = true,
    file_panel = { listing_style = "tree" },
    view = {
      default = { layout = "diff2_vertical", winbar_info = true },
      file_history = { layout = "diff2_vertical", winbar_info = true },
    },
    hooks = {
      diff_buf_read = function(bufnr)
        -- Trigger BufReadPost so treesitter-context recognizes diff buffers
        vim.api.nvim_exec_autocmds("BufReadPost", { buffer = bufnr })
      end,
      diff_buf_win_enter = function(bufnr, winid)
        -- Show full file content without folding unchanged lines
        vim.wo[winid].foldenable = false
        -- Give the bottom (new) diff pane more vertical space
        vim.schedule(function()
          local diff_wins = {}
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.wo[win].diff then
              table.insert(diff_wins, { win = win, row = vim.api.nvim_win_get_position(win)[1] })
            end
          end
          if #diff_wins >= 2 then
            table.sort(diff_wins, function(a, b) return a.row < b.row end)
            local total = vim.api.nvim_win_get_height(diff_wins[1].win)
              + vim.api.nvim_win_get_height(diff_wins[2].win)
            vim.api.nvim_win_set_height(diff_wins[1].win, math.floor(total * 0.35))
          end
        end)
      end,
      view_opened = function()
        -- Hide the default tabline (shows file paths when diffview creates a new tab)
        vim._diffview_saved_showtabline = vim.o.showtabline
        vim.opt.showtabline = 0
      end,
      view_closed = function()
        vim.opt.showtabline = vim._diffview_saved_showtabline or 1
        vim._diffview_saved_showtabline = nil
      end,
    },
    keymaps = {
      view = { q = "<cmd>DiffviewClose<cr>" },
      file_panel = { q = "<cmd>DiffviewClose<cr>" },
      file_history_panel = { q = "<cmd>DiffviewClose<cr>" },
    },
  },
}
