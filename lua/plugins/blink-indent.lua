-- blink-indent.lua
--
-- Created: 12/29/25
--
-- Using instead of other indent plugin
-- re-written for new re-write of treesitter
-- version of nvim-biscuits not compatibe

return {
  'saghen/blink.indent',
  event = 'InsertEnter',
  config = function()
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
  end,
}
