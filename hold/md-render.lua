-- md-render.lua

-- Created: 08/30/26

vim.pack.add({
  'https://github.com/delphinus/md-render.nvim',
  -- optional:
  'https://github.com/delphinus/budoux.lua',
})

require('md-render').setup({

  Kset('n', '<Leader>vp', '<Plug>(md-render-preview)', { desc = 'Markdown preview (toggle)' }),
  Kset('n', '<Leader>vt', '<Plug>(md-render-preview-tab)', { desc = 'Markdown preview tab' }),

  -- keys = {
  --   { '<Leader>mp', '<Plug>(md-render-preview)', desc = 'Markdown preview (toggle)' },
  --   { '<Leader>mt', '<Plug>(md-render-preview-tab)', desc = 'Markdown preview in tab (toggle)' },
  --   { '<Leader>md', '<Plug>(md-render-demo)', desc = 'Markdown render demo' },
  -- },
})
