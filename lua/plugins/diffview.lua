-- Side-by-side diff viewer with syntax highlighting and file history
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    -- No rev given, so this is index-relative: uncommitted work only.
    -- (--imply-local is inert without a range rev, but harmless.)
    { "<leader>gd", "<cmd>DiffviewOpen --imply-local<cr>", desc = "Diff view (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },

    -- Review: upstream...HEAD, i.e. what a CR would show. See lua/review.lua.
    { "<leader>gc", function() require("review").review_pick() end, desc = "Review CR (all packages, or pick one)" },
    { "<leader>gq", function() require("review").changed_to_quickfix() end, desc = "Changed files to quickfix (all pkgs)" },
    { "<leader>gb", function() require("review").toggle_base() end, desc = "Toggle gitsigns base (index / upstream)" },
    { "<leader>gf", function() require("review").find_changed() end, desc = "Find in changed files (all pkgs)" },
    { "<leader>gg", function() require("review").grep_changed() end, desc = "Grep changed files (all pkgs)" },
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
        -- Split the two diff panes unevenly, favouring the bottom (new) side
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
            -- Fraction of the vertical space given to the top (old/base) pane.
            -- Renders a few points lower than set: winbar rows are not part of
            -- the window height being divided.
            vim.api.nvim_win_set_height(diff_wins[1].win, math.floor(total * 0.40))
            -- Disable scrollbind (which syncs topline, not cursor-relative position)
            -- and rely on cursorbind + scrolloff=999 to keep both panes centered
            for _, dw in ipairs(diff_wins) do
              vim.wo[dw.win].scrollbind = false
              vim.wo[dw.win].scrolloff = 999
            end
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
