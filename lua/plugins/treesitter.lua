-- Treesitter parsers + highlighting.
--
-- Pinned to `master`, NOT `main`, deliberately. The two branches differ in how
-- parsers get built:
--   main   -> generates grammars with the `tree-sitter` CLI (a Rust binary)
--   master -> ships pre-generated parser.c and compiles it with the system cc
-- Every prebuilt `tree-sitter` CLI (0.24-0.26) needs glibc >= 2.28; this host is
-- Amazon Linux 2 with glibc 2.26, so the CLI cannot run and `main` can install
-- nothing. `master` only needs a C compiler, which is present.
--
-- Symptom if this regresses: only Neovim's bundled parsers (c, lua, markdown,
-- query, vim, vimdoc) highlight, and everything else silently falls back to regex
-- syntax. Note vim.treesitter.language.add() returns true even with no compiled
-- parser (it only registers a filetype mapping), so the failure surfaces later as
-- "Parser could not be created for buffer".
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  -- master registers its query predicates/directives with { all = false }, expecting
  -- one node per capture. Neovim 0.12 ignores that flag and always passes a list, so
  -- e.g. #set-lang-from-info-string! errors on every markdown code fence
  -- ("attempt to call method 'range'"). Hand those handlers the last node, which is
  -- what all = false used to do. Must run before the plugin loads its predicates.
  init = function()
    local q = vim.treesitter.query
    local function single_node(handler)
      return function(match, ...)
        local m = {}
        for id, nodes in pairs(match) do
          m[id] = type(nodes) == "table" and nodes[#nodes] or nodes
        end
        return handler(m, ...)
      end
    end
    for _, name in ipairs({ "add_predicate", "add_directive" }) do
      local orig = q[name]
      q[name] = function(n, handler, opts)
        if type(opts) == "table" and opts.all == false then
          handler = single_node(handler)
        end
        return orig(n, handler, opts)
      end
    end
  end,
  build = ":TSUpdate",
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash",
      "bitbake", -- Yocto .bb / .bbappend / .inc
      "c",
      "diff",
      "dockerfile",
      "git_config",
      "gitcommit",
      "gitignore",
      "json",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "python",
      "rust",
      "toml",
      "typescript",
      "yaml",
    },
    auto_install = true,
    highlight = { enable = true },
  },
}
