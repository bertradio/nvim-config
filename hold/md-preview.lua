-- md-preview.lua

-- Created: 11/04/26

vim.pack.add({
  { src = Gh('ywsrock/nvim-md-preview') },
})

require('md_preview').setup({
  theme = 'light',
  git_diff_base = 'main',
  export = { paper = 'us-letter', toc = true },
})
