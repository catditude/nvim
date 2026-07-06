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
  config = function(_, opts)
    require("image").setup(opts)

    -- Double-wrap kitty graphics for NESTED tmux (laptop-tmux -> ssh -> remote-tmux, i.e. the
    -- ARM cloud desktop). image.nvim wraps the passthrough sequence once; with two tmux layers
    -- the inner tmux unwraps that single wrap and the outer tmux then swallows the now-raw
    -- kitty sequence -> an unpainted black block. Wrapping twice lets each layer strip exactly
    -- one level so the real terminal receives the raw sequence and paints. Verified 2026-07-06.
    -- Gated on tmux-over-ssh so the laptop's single-tmux case is untouched (no-op there).
    -- NOTE: require with the slash form the plugin uses ("image/utils/tmux") so we mutate the
    -- same cached module table its call sites read.
    local tmux = require("image/utils/tmux")
    if tmux.is_tmux and (vim.env.SSH_TTY ~= nil or vim.env.SSH_CLIENT ~= nil) then
      local wrap_once = tmux.escape
      tmux.escape = function(sequence)
        return wrap_once(wrap_once(sequence))
      end
    end
  end,
}
