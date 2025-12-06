-- nvim-surround.lua
--
-- Created: 07/30/25

return {
  'kylechui/nvim-surround',
  version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup({
      -- Configuration here, or leave empty to use defaults
    })
  end,
}
