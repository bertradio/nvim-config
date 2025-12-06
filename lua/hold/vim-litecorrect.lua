-- autocorrect.lua
--
-- Created: 11/24/23

-- setup for liteautocorrect

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
augroup('Myfn.LiteCorrect_Settings', { clear = true })
autocmd({ 'BufNewFile', 'BufEnter' }, {
  group = 'Myfn.LiteCorrect_Settings',
  pattern = { '*.md, *.txt' },
  command = 'call litecorrect#init()',
})

return {
  'preservim/vim-litecorrect',
}
