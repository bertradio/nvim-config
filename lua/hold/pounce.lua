-- pounce.lua
--
-- Created: 11/11/24

local map = vim.keymap.set

map('n', 'f', function()
  require('pounce').pounce({})
end)

map('n', 'F', function()
  require('pounce').pounce({ do_repeat = true })
end)

return {
  'rlane/pounce.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
}
