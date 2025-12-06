-- frecency.lua

-- Created: 12/31/23

vim.keymap.set('n', '<Leader>fy', '<Cmd>Telescope frecency workspace=CWD <CR>')
-- vim.keymap.set('n', '<Leader>fyn', '<Cmd>Telescope frecency workspace=nvim<CR>')
-- vim.keymap.set('n', '<Leader>fyp', '<Cmd>Telescope frecency workspace=plug<CR>')

return {
  'nvim-telescope/telescope-frecency.nvim',
  lazy = true,
  config = function()
    require('telescope').load_extension('frecency')
  end,
}
