-- csearch.lua
--
-- Created: 05/01/25

return {
  'hamidi-dev/kaleidosearch.nvim',
  dependencies = {
    -- 'tpope/vim-repeat', -- optional for dot-repeatability
    -- 'stevearc/dressing.nvim', -- optional for nice input
  },

  config = function()
    require('kaleidosearch').setup({
      -- optional configuration
    })
  end,
}
