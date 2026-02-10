-- smart-paste.lua
--
-- Modifies paste to follow indent of target
--
-- Created: 02/09/26

return {
  'nemanjamalesija/smart-paste.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('smart-paste').setup({
      keys = { 'p', 'P', 'gp', 'gP' }, -- keys to enhance (default)
      'nemanjamalesija/smart-paste.nvim',
      exclude_filetypes = {}, -- filetypes that skip smart indent
    })
  end,
}
