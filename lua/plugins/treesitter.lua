return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- Auto-install missing treesitter parsers when a buffer is opened
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        local ok = pcall(vim.treesitter.language.add, lang)
        if not ok then
          vim.cmd("TSInstall " .. lang)
        end
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
