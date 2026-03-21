vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "1989"
vim.o.background = "dark"

-- Color palette
local colors = {
  -- Grays
  dark_gray = "#1c1c1c",
  charcoal = "#262626",
  dim_gray = "#303030",
  soft_gray = "#333333",
  light_gray = "#444444",
  muted = "#505058",
  comment_gray = "#6a6a7a",
  mid_gray = "#878787",
  white = "#FFFFFF",
  -- Purples / Pinks
  lavender = "#dfafff",
  light_pink = "#F0C4C8",
  gray_purple = "#afafd7",
  pink = "#f075a0",
  dark_pink = "#ff005f",
  flash_pink = "#FF8DA1",
  -- Blues
  light_blue = "#A2CFFE",
  dark_blue = "#0087af",
  -- Greens / Yellows
  mint = "#9EB294",
  light_yellow = "#ffffaf",
  dark_green = "#00875f",
  orange = "#FFC067",
  -- Diff backgrounds
  diff_add = "#2a3a2a",
  diff_delete = "#3a2a2a",
  diff_change = "#2a2a3a",
  diff_text = "#2a5a2a",
  diff_delete_strong = "#6b2a2a",
  diff_change_strong = "#2a2a5a",
  -- Search
  search_bg = "#4a4a1a",
  -- Diffview panel
  diffview_insert = "#b5e8b0",
  diffview_delete = "#e88a8a",
  -- Diagnostic underlines
  error_undercurl = "#e06070",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- UI elements
hi("Normal", { fg = colors.white, bg = colors.dark_gray })
hi("Cursor", { fg = colors.dark_gray, bg = colors.white })
hi("Visual", { bg = colors.light_gray, blend = 50 })
hi("CursorLine", { bg = colors.charcoal })
hi("CursorLineNr", { fg = colors.white, bg = colors.charcoal, bold = true })
hi("CursorColumn", { bg = colors.light_gray })
hi("ColorColumn", { bg = colors.light_gray })
hi("LineNr", { fg = colors.mid_gray, bg = colors.dark_gray })
hi("VertSplit", { fg = colors.muted, bg = colors.dark_gray })
hi("WinSeparator", { fg = colors.muted, bg = colors.dark_gray })
hi("MatchParen", { fg = colors.pink, underline = true })
hi("StatusLine", { fg = colors.white, bg = colors.mid_gray, bold = true })
hi("StatusLineNC", { fg = colors.white, bg = colors.mid_gray })
hi("Pmenu", {})
hi("PmenuSel", { bg = colors.dark_gray })
hi("IncSearch", { fg = colors.dark_gray, bg = colors.light_yellow })
hi("Search", { fg = colors.white, bg = colors.search_bg })
hi("CurSearch", { fg = colors.dark_gray, bg = colors.light_yellow })
hi("Directory", { fg = colors.lavender })
hi("Folded", { fg = colors.light_yellow, bg = colors.dark_gray })
hi("FloatBorder", { fg = colors.gray_purple, bg = colors.dark_gray })
hi("TabLine", { fg = colors.white, bg = colors.dark_gray })
hi("TabLineSel", { fg = colors.light_pink, bg = colors.dark_gray })
hi("TabLineFill", { fg = colors.white, bg = colors.dark_gray })

-- Diff
hi("Define", { fg = colors.gray_purple })
hi("DiffAdd", { bg = colors.diff_add })
hi("DiffDelete", { bg = colors.diff_delete })
hi("DiffChange", { bg = colors.diff_change })
hi("DiffText", { bg = colors.diff_text, bold = true })
hi("ErrorMsg", { fg = colors.white, bg = colors.dark_pink })
hi("WarningMsg", { fg = colors.white, bg = colors.dark_pink })

-- Syntax
hi("Boolean", { fg = colors.lavender })
hi("Character", { fg = colors.lavender })
hi("Comment", { fg = colors.comment_gray })
hi("Conditional", { fg = colors.pink })
hi("Constant", { fg = colors.mint })
hi("Float", { fg = colors.lavender })
hi("Function", { fg = colors.light_pink })
hi("Identifier", { fg = colors.light_pink })
hi("Keyword", { fg = colors.pink })
hi("Label", { fg = colors.light_yellow })
hi("NonText", { fg = colors.white, bg = colors.dark_gray })
hi("Number", { fg = colors.mint })
hi("Operator", { fg = colors.pink })
hi("PreProc", { fg = colors.pink })
hi("Special", { fg = colors.light_pink })
hi("SpecialKey", { fg = colors.white, bg = colors.dark_gray })
hi("Statement", { fg = colors.pink })
hi("SpellBad", { fg = colors.pink, underline = true })
hi("SpellCap", { fg = colors.light_blue, underline = true })
hi("StorageClass", { fg = colors.mint })
hi("String", { fg = colors.light_blue })
hi("Tag", { fg = colors.pink })
hi("Title", { fg = colors.white, bold = true })
hi("Todo", { fg = colors.light_yellow, bg = colors.dark_gray, bold = true })
hi("Type", { fg = colors.mint })
hi("Underlined", { underline = true })

-- Ruby
hi("rubyClass", { fg = colors.pink })
hi("rubyFunction", { fg = colors.light_pink })
hi("rubySymbol", { fg = colors.light_pink })
hi("rubyConstant", { fg = colors.mint })
hi("rubyStringDelimiter", { fg = colors.light_blue })
hi("rubyBlockParameter", { fg = colors.pink })
hi("rubyInstanceVariable", { fg = colors.pink })
hi("rubyInclude", { fg = colors.pink })
hi("rubyGlobalVariable", { fg = colors.light_yellow })
hi("rubyRegexp", { fg = colors.light_yellow })
hi("rubyRegexpDelimiter", { fg = colors.light_yellow })
hi("rubyEscape", { fg = colors.lavender })
hi("rubyControl", { fg = colors.lavender })
hi("rubyRepeat", { fg = colors.lavender })
hi("rubyConditional", { fg = colors.pink })
hi("rubyClassVariable", { fg = colors.light_yellow })
hi("rubyOperator", { fg = colors.pink })
hi("rubyException", { fg = colors.mint })
hi("rubyPseudoVariable", { fg = colors.mint })
hi("rubyRailsUserClass", { fg = colors.mint })
hi("rubyRailsARAssociationMethod", { fg = colors.mint })
hi("rubyRailsARMethod", { fg = colors.mint })
hi("rubyRailsRenderMethod", { fg = colors.mint })
hi("rubyRailsMethod", { fg = colors.mint })
hi("rubyArrayDelimiter", { fg = colors.pink })
hi("rubyInterpolation", { fg = colors.light_pink })
hi("rubyInterpolationDelimiter", { fg = colors.pink })

-- ERB
hi("erubyRailsMethod", { fg = colors.mint })

-- HTML
hi("htmlSpecialChar", { fg = colors.lavender })

-- JavaScript
hi("javaScriptFunction", { fg = colors.mint })
hi("javaScriptRailsFunction", { fg = colors.mint })
hi("jsThis", { fg = colors.pink })
hi("jsBraces", { fg = colors.light_pink })
hi("jsGlobalObjects", { fg = colors.mint })

-- YAML
hi("yamlKey", { fg = colors.pink })
hi("yamlDocumentHeader", { fg = colors.light_yellow })
hi("yamlPlainScalar", { fg = colors.light_blue })
hi("yamlBlockCollectionItemStart", { fg = colors.pink })

-- CSS
hi("cssURL", { fg = colors.dark_pink })
hi("cssFunctionName", { fg = colors.mint })
hi("cssColor", { fg = colors.lavender })
hi("cssPseudoClassId", { fg = colors.light_yellow })
hi("cssClassName", { fg = colors.light_yellow })
hi("cssValueLength", { fg = colors.lavender })
hi("cssCommonAttr", { fg = colors.mint })

-- CoffeeScript
hi("coffeeCurly", { fg = colors.lavender })
hi("coffeeObjAssign", { fg = colors.light_pink })

-- CJSX
hi("cjsxAttribProperty", { fg = colors.lavender })

-- Markdown
hi("markdownH1", { fg = colors.light_blue })
hi("markdownH2", { fg = colors.light_blue })
hi("markdownH3", { fg = colors.light_blue })
hi("markdownH4", { fg = colors.light_blue })
hi("markdownH5", { fg = colors.light_blue })
hi("markdownH6", { fg = colors.light_blue })
hi("markdownHeadingDelimiter", { fg = colors.light_blue })
hi("markdownRule", { fg = colors.light_blue })

-- Diagnostics
hi("DiagnosticError", { fg = colors.dark_pink })
hi("DiagnosticWarn", { fg = colors.light_yellow })
hi("DiagnosticInfo", { fg = colors.light_blue })
hi("DiagnosticHint", { fg = colors.mint })
hi("DiagnosticUnderlineError", { undercurl = true, sp = colors.error_undercurl })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.light_yellow })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.light_blue })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = colors.mint })

-- Gitsigns gutter signs
hi("GitSignsAdd", { fg = colors.mint })
hi("GitSignsChange", { fg = colors.orange })
hi("GitSignsDelete", { fg = colors.dark_pink })

-- Gitsigns current line blame
hi("GitSignsCurrentLineBlame", { fg = colors.muted, italic = true })

-- Gitsigns preview (floating window)
hi("GitSignsAddPreview", { fg = colors.mint, bg = colors.diff_add })
hi("GitSignsDeletePreview", { fg = colors.light_pink, bg = colors.diff_delete })

-- Gitsigns inline preview (deleted virtual lines)
hi("GitSignsDeleteVirtLn", { fg = colors.light_pink, bg = colors.diff_delete })
hi("GitSignsDeleteVirtLnInLine", { bg = colors.diff_delete_strong })

-- Gitsigns word-level diff regions in inline previews
hi("GitSignsAddInline", { bg = colors.diff_text })
hi("GitSignsDeleteInline", { bg = colors.diff_delete_strong })
hi("GitSignsChangeInline", { bg = colors.diff_change_strong })

-- Treesitter context (sticky scope header)
hi("TreesitterContext", { bg = colors.soft_gray })

-- Navic breadcrumbs (statusline code location)
hi("NavicText", { fg = colors.white })
hi("NavicSeparator", { fg = colors.gray_purple })
hi("NavicIconsFunction", { fg = colors.light_pink })
hi("NavicIconsMethod", { fg = colors.light_pink })
hi("NavicIconsStruct", { fg = colors.mint })
hi("NavicIconsClass", { fg = colors.mint })
hi("NavicIconsModule", { fg = colors.pink })
hi("NavicIconsEnum", { fg = colors.mint })
hi("NavicIconsInterface", { fg = colors.light_blue })
hi("NavicIconsVariable", { fg = colors.light_yellow })
hi("NavicIconsConstant", { fg = colors.mint })
hi("NavicIconsField", { fg = colors.lavender })
hi("NavicIconsProperty", { fg = colors.lavender })

-- Telescope symbol kinds
hi("TelescopeResultsFunction", { fg = colors.light_pink })
hi("TelescopeResultsMethod", { fg = colors.light_pink })
hi("TelescopeResultsClass", { fg = colors.mint })
hi("TelescopeResultsStruct", { fg = colors.mint })
hi("TelescopeResultsConstant", { fg = colors.mint })
hi("TelescopeResultsField", { fg = colors.lavender })
hi("TelescopeResultsVariable", { fg = colors.light_yellow })
hi("TelescopeResultsOperator", { fg = colors.pink })

-- Indent guides (blink.indent)
hi("BlinkIndent", { fg = colors.dim_gray })
hi("BlinkIndentScope", { fg = colors.gray_purple })

-- Dashboard (snacks.nvim)
hi("SnacksDashboardHeader", { fg = colors.light_blue })
hi("SnacksDashboardKey", { fg = colors.pink, bold = true })
hi("SnacksDashboardDesc", { fg = colors.white })
hi("SnacksDashboardIcon", { fg = colors.light_pink })
hi("SnacksDashboardFooter", { fg = colors.mid_gray })

-- Noice (cmdline + messages)
hi("NoiceCmdlinePopupBorder", { fg = colors.gray_purple })
hi("NoiceCmdlineIcon", { fg = colors.pink })
hi("NoiceCmdlineIconSearch", { fg = colors.light_yellow })

-- LSP
hi("LspInlayHint", { fg = colors.muted, italic = true })

-- Diffview file panel
hi("DiffviewFilePanelInsertions", { fg = colors.diffview_insert })
hi("DiffviewFilePanelDeletions", { fg = colors.diffview_delete })

-- render-markdown.nvim headings (foreground only, no background highlight)
hi("RenderMarkdownH1", { fg = colors.pink, bold = true })
hi("RenderMarkdownH2", { fg = colors.lavender, bold = true })
hi("RenderMarkdownH3", { fg = colors.light_blue, bold = true })
hi("RenderMarkdownH4", { fg = colors.mint, bold = true })
hi("RenderMarkdownH5", { fg = colors.light_yellow, bold = true })
hi("RenderMarkdownH6", { fg = colors.gray_purple, bold = true })
hi("RenderMarkdownH1Bg", { fg = colors.pink, bold = true })
hi("RenderMarkdownH2Bg", { fg = colors.lavender, bold = true })
hi("RenderMarkdownH3Bg", { fg = colors.light_blue, bold = true })
hi("RenderMarkdownH4Bg", { fg = colors.mint, bold = true })
hi("RenderMarkdownH5Bg", { fg = colors.light_yellow, bold = true })
hi("RenderMarkdownH6Bg", { fg = colors.gray_purple, bold = true })

-- Flash
hi("FlashLabel", { fg = colors.dark_gray, bg = colors.flash_pink, bold = true })
