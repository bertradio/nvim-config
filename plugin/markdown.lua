-- markdown.lua
-- changed from lazy to vim.pack 3-30-26
--
-- Created: 03/21/24

vim.pack.add({ 'https://github.com/MeanderingProgrammer/markdown.nvim' })
name = 'render-markdown' -- Only needed if you have another plugin named markdown.nvim
require('render-markdown').setup({
  latex = { enabled = false },
  html = { enabled = false },
  yaml = { enabled = false },
  completions = { lsp = { enabled = true } },
})
