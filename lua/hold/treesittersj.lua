-- treesittersj.lua

-- Created: 11/18/23

return {
  'Wansmer/treesj',
  keys = { '<space>m', '<space>j', '<space>s' },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({--[[ your config ]]})
  end,
}

