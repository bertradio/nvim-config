-- circadia.lua

-- Created: 08/21/26

vim.pack.add({
  'https://github.com/tanmaymanojgandhi/circadia',
})

vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/core/opt/circadia/ports/vim')

vim.cmd([[ set background = 'light' ]])
vim.cmd([[ set termguicolors ]])
vim.cmd.colorscmeme('circadia_light')
