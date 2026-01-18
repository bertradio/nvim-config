-- neogit.lua
--
-- Created: 12/27/25

return {
  'NeogitOrg/neogit',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'ibhagwan/fzf-lua', -- optional
  },
  cmd = 'Neogit',
  keys = {
    { '<leader>gn', '<cmd>Neogit<cr>', desc = 'Neogit' },
  },
}
