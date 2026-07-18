vim.pack.add({
  { src = 'https://github.com/kevinhwang91/nvim-hlslens' },
})

vim.opt.hlsearch = true
vim.opt.shortmess:append('S')

local hlslens = require('hlslens')

hlslens.setup({
  nearest_only = true,
  nearest_float_when = 'never',
  calm_down = false,
})

local function set_search_highlights()
  vim.api.nvim_set_hl(0, 'Search', {
    bg = '#45475a',
    fg = '#f5e0dc',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'CurSearch', {
    bg = '#f9e2af',
    fg = '#1e1e2e',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'HlSearchLens', {
    fg = '#9399b2',
    italic = true,
  })

  vim.api.nvim_set_hl(0, 'HlSearchLensNear', {
    fg = '#f9e2af',
    bold = true,
  })
end

set_search_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('HlslensSearchHighlights', { clear = true }),
  callback = set_search_highlights,
})

vim.keymap.set('n', 'n', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'n')
  hlslens.start()
end, { silent = true, desc = 'Next search result' })

vim.keymap.set('n', 'N', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'N')
  hlslens.start()
end, { silent = true, desc = 'Previous search result' })
