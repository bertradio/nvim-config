-- blink-indent.lua
-- changed from lazy to vim.pack 3-30-26
--
-- Created: 12/29/25
--
-- Using instead of other indent plugin
-- re-written for new re-write of treesitter

vim.pack.add({ 'https://github.com/saghen/blink.indent' })
vim.g.indent_guide = false -- start with guides disabled

local indent = require('blink.indent')

vim.keymap.set('n', '<Leader>i', function()
  indent.enable(not indent.is_enabled())
end, { desc = 'Toggle indent guides' })

indent.setup({
  scope = {
    -- enable to show underlines on the line above the current scope
    underline = {
      enabled = true,
      highlights = {
        'BlinkIndentOrangeUnderline',
        'BlinkIndentVioletUnderline',
        'BlinkIndentBlueUnderline',
      },
    },
  },
})
