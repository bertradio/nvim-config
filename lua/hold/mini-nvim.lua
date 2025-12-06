-- mini-nvim.lua

-- Created: 11/25/23

-- simple mini modules - complex ones with params are in separate files

return {

  'echasnovski/mini.nvim',

	-- stylua: ignore
  config = function()
    require('mini.animate').setup()
		require('mini.pairs' ).setup()
   	require('mini.surround').setup()
	end,
}
