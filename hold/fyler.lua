-- fyler.lua

-- Created: 09/05/26

vim.pack.add({ 'https://github.com/FylerOrg/fyler.nvim' })

local fyler = require('fyler')

-- open using defaults
fyler.open()

-- open as a left most split
fyler.open({ kind = 'split_left_most' })

-- open with different directory
fyler.open({ root_path = '~' })

-- You can map this to a key
vim.keymap.set('n', '<leader>f', fyler.open, { desc = 'Fyler.nvim - Open' })

-- Wrap in a function to pass additional arguments
vim.keymap.set('n', '<leader>f', function()
  fyler.open({ kind = 'split_left_most' })
end, { desc = 'Fyler.nvim - Open' })
