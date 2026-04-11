-- smart-paste.lua
-- changed from lazy to vim.pack 3-30-26
--
-- Modifies paste to follow indent of target
--
-- Created: 02/09/26

vim.pack.add({ 'src = https://github.com/nemanjamalesija/smart-paste.nvim' })

require('smart-paste').setup({})
--   keys = { 'p', 'P', 'gp', 'gP' }, -- keys to enhance (default)
--   'nemanjamalesija/smart-paste.nvim',
--   exclude_filetypes = {}, -- filetypes that skip smart indent
-- })
