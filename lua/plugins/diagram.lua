return {
  "3rd/diagram.nvim",
  dependencies = { "3rd/image.nvim" },
  ft = { "markdown" },
  config = function()
    local diagram = require("diagram")
    local md = require("diagram/integrations").markdown

    -- Replace the built-in mmdc-based mermaid renderer with our Kroki renderer.
    -- md.renderers is an ordered list of { id = ..., render = ... } modules;
    -- diagram.nvim matches a fence's language to a renderer by `id`.
    local kroki = require("diagram_kroki")
    local renderers = {}
    for _, r in ipairs(md.renderers) do
      if r.id ~= "mermaid" then table.insert(renderers, r) end
    end
    table.insert(renderers, 1, kroki) -- our mermaid renderer first

    local markdown_integration = vim.tbl_extend("force", md, { renderers = renderers })

    diagram.setup({
      integrations = { markdown_integration },
      renderer_options = {
        mermaid = { kroki_url = "http://localhost:8000" },
      },
    })
  end,
}
