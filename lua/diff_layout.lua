-- Pick the Diffview layout by window width, re-evaluated on each open so that
-- zooming the tmux pane (prefix+z) flips between stacked and side-by-side.
-- Side-by-side needs ~2*(80 code + gutter) + 35 file panel to avoid wrapping,
-- hence the ~210 default. Tune min_width to your zoomed pane width (:echo &columns).
local M = {}

M.min_width = 210

function M.apply()
  local layout = vim.o.columns >= M.min_width and "diff2_horizontal" or "diff2_vertical"
  local view = require("diffview.config").get_config().view
  view.default.layout = layout
  view.file_history.layout = layout
end

return M
