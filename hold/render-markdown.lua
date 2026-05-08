--    ╭────────────────────────────╮
--    │    render-markdown.lua     │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26

-- Created: 03/21/24

vim.pack.add({
  { src = Gh('MeanderingProgrammer/markdown.nvim'), name = 'render-markdown' },
})

-- stylua: ignore 
require('render-markdown').setup({
  latex       = { enabled = false },
  html        = { enabled = false },
  yaml        = { enabled = false },
  completions = { lsp = { enabled = true } },
})
