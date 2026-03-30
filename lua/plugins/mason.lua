-- lspconfig.lua
--
-- Created: 12/10/23

vim.pack.add({ 'https://github.com/williamboman/mason-lspconfig.nvim' })
vim.pack.add({ 'https://github.com/williamboman/mason.nvim' })

cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' }
require('mason').setup()
