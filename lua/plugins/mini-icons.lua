-- Icons provider (replaces nvim-web-devicons)
return {
  "echasnovski/mini.icons",
  lazy = false,
  opts = {},
  init = function()
    -- Provide nvim-web-devicons API for plugins that expect it (e.g. diffview)
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
}
