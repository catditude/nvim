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
}
