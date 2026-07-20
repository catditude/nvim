return {
  "3rd/image.nvim",
  build = false, -- use magick_cli (ImageMagick 6 `convert`), skip the luarocks magick_rock build
  ft = { "markdown" },
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = {}, -- diagram.nvim drives rendering; disable built-in md/norg image integrations
    max_width_window_percentage = 90,
    tmux_show_only_in_active_window = true,
  },
  -- Single tmux everywhere now (kitty sshes straight into the remote tmux; no
  -- laptop tmux wrapping the ssh). image.nvim's built-in single passthrough wrap
  -- is correct for one tmux layer, so no escape monkeypatch is needed. The old
  -- double-wrap (for the nested laptop-tmux -> ssh -> remote-tmux path) was
  -- removed with the single-tmux migration — it would now OVER-wrap and paint a
  -- black block. See ~/computa/CLAUDE.md.
}
