-- scratch-nvim.lua
--
-- Created: 03/20/25

vim.keymap.set('n', '<Leader>.n', '<cmd>ScratchWithName<cr>')
vim.keymap.set('n', '<Leader>.o', '<cmd>ScratchOpen<cr>')

return {
  {
    'LintaoAmons/scratch.nvim',
    event = 'VeryLazy',
  },
}
