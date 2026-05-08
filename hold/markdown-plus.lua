-- markdown-plus.lua

-- Created: 05/07/26

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.pack.add('markdown-plus.nvim')
    require('markdown-plus').setup({})
  end,
})
