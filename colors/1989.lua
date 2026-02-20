vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "1989"
vim.o.background = "dark"

-- Color palette
-- Grays:   dark_gray < light_gray < mid_gray < white
-- Purples: gray_purple (muted) < lavender (cool) < light_purple (warm blush)
-- Pinks:   pink (medium) < light_purple (light rose) | dark_pink (vivid)
-- Blues:   dark_blue < light_blue
-- Others:  mint (green), light_yellow (cream), dark_green
local colors = {
  dark_gray = "#1c1c1c",
  mid_gray = "#878787",
  light_gray = "#444444",
  white = "#FFFFFF",
  lavender = "#dfafff",
  light_purple = "#F0C4C8",
  gray_purple = "#afafd7",
  pink = "#f075a0",
  light_blue = "#A2CFFE",
  mint = "#9EB294",
  light_yellow = "#ffffaf",
  dark_pink = "#ff005f",
  dark_green = "#00875f",
  dark_blue = "#0087af",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- UI elements
hi("Normal", { fg = colors.white, bg = colors.dark_gray })
hi("Cursor", { fg = colors.dark_gray, bg = colors.white })
hi("Visual", { bg = colors.light_gray, blend = 50 })
hi("CursorLine", { bg = colors.light_gray })
hi("CursorColumn", { bg = colors.light_gray })
hi("ColorColumn", { bg = colors.light_gray })
hi("LineNr", { fg = colors.mid_gray, bg = colors.dark_gray })
hi("VertSplit", { fg = colors.mid_gray, bg = colors.mid_gray })
hi("MatchParen", { fg = colors.pink, underline = true })
hi("StatusLine", { fg = colors.white, bg = colors.mid_gray, bold = true })
hi("StatusLineNC", { fg = colors.white, bg = colors.mid_gray })
hi("Pmenu", {})
hi("PmenuSel", { bg = colors.dark_gray })
hi("IncSearch", { fg = colors.dark_gray, bg = colors.light_yellow })
hi("Search", { underline = true })
hi("Directory", { fg = colors.lavender })
hi("Folded", { fg = colors.light_yellow, bg = colors.dark_gray })
hi("TabLine", { fg = colors.white, bg = colors.dark_gray })
hi("TabLineSel", { fg = colors.light_purple, bg = colors.dark_gray })
hi("TabLineFill", { fg = colors.white, bg = colors.dark_gray })

-- Diff
hi("Define", { fg = colors.gray_purple })
hi("DiffAdd", { fg = colors.white, bg = colors.dark_green, bold = true })
hi("DiffDelete", { fg = colors.dark_pink })
hi("DiffChange", { fg = colors.white, bg = colors.dark_gray })
hi("DiffText", { fg = colors.white, bg = colors.dark_blue, bold = true })
hi("ErrorMsg", { fg = colors.white, bg = colors.dark_pink })
hi("WarningMsg", { fg = colors.white, bg = colors.dark_pink })

-- Syntax
hi("Boolean", { fg = colors.lavender })
hi("Character", { fg = colors.lavender })
hi("Comment", { fg = "#6a6a7a" })
hi("Conditional", { fg = colors.pink })
hi("Constant", { fg = colors.mint })
hi("Float", { fg = colors.lavender })
hi("Function", { fg = colors.light_purple })
hi("Identifier", { fg = colors.light_purple })
hi("Keyword", { fg = colors.pink })
hi("Label", { fg = colors.light_yellow })
hi("NonText", { fg = colors.white, bg = colors.dark_gray })
hi("Number", { fg = colors.mint })
hi("Operator", { fg = colors.pink })
hi("PreProc", { fg = colors.pink })
hi("Special", { fg = colors.light_purple })
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
hi("rubyFunction", { fg = colors.light_purple })
hi("rubySymbol", { fg = colors.light_purple })
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
hi("rubyInterpolation", { fg = colors.light_purple })
hi("rubyInterpolationDelimiter", { fg = colors.pink })

-- ERB
hi("erubyDelimiter", {})
hi("erubyRailsMethod", { fg = colors.mint })

-- HTML
hi("htmlTag", {})
hi("htmlEndTag", {})
hi("htmlTagName", {})
hi("htmlArg", {})
hi("htmlSpecialChar", { fg = colors.lavender })

-- JavaScript
hi("javaScriptFunction", { fg = colors.mint })
hi("javaScriptRailsFunction", { fg = colors.mint })
hi("javaScriptBraces", {})
hi("jsThis", { fg = colors.pink })
hi("jsBraces", { fg = colors.light_purple })
hi("jsGlobalObjects", { fg = colors.mint })

-- YAML
hi("yamlKey", { fg = colors.pink })
hi("yamlAnchor", {})
hi("yamlAlias", {})
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
hi("cssBraces", {})

-- CoffeeScript
hi("coffeeCurly", { fg = colors.lavender })
hi("coffeeObjAssign", { fg = colors.light_purple })

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
hi("DiagnosticUnderlineError", { undercurl = true, sp = "#e06070" })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.light_yellow })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.light_blue })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = colors.mint })

-- LSP
hi("LspInlayHint", { fg = colors.mid_gray, italic = true })
