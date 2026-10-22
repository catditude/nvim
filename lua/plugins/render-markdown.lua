return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  opts = {
    heading = { sign = false, width = 'block', right_pad = 1, border = true },
    code = { sign = false, width = 'block', right_pad = 2, border = 'thin' },
    -- Tables are drawn by lua/md_table.lua (floats with wrapped cells).
    pipe_table = { enabled = false },
    -- Keep the cursor line rendered. Disabling anti_conceal also sets concealcursor,
    -- so treesitter conceals (**, `, link URLs) stay hidden on the cursor line too.
    anti_conceal = { enabled = false },
  },
}
