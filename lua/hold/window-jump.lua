-- window-jump.lua
--
-- Created: 11/10/24

-- to jump to other windows

return {
  'yorickpeterse/nvim-window',
  keys = {
    {
      '<leader>wj',
      "<cmd>lua require('nvim-window').pick()<cr>",
      desc = 'nvim-window: Jump to window',
    },
  },
}
