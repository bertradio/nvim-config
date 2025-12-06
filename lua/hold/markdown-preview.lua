-- markdown-preview.lua

-- Created: 05/16/24

return {

  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown', 'md' },
  build = function()
    vim.fn['mkup@util#install']()
  end,
}
