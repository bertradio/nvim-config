-- flash.lua
--
-- Created: 10/27/25

return {
	'folke/flash.nvim',
	event = 'VeryLazy',
	opts  = {
		jump  = { autojump = true },
		modes = {
			search = { enabled = true },
			char   = { jump_labels = true },
		},
	},
	keys  = {
		{
			's',
			mode = { 'n', 'x', 'o' },
			function()
				require('flash').jump()
			end,
			desc = 'Flash',
		},
		{
			'S',
			mode = { 'n', 'x', 'o' },
			function()
				require('flash').treesitter()
			end,
			desc = 'Flash Treesitter',
		},
		{
			'<c-f>',
			mode = { 'c' },
			function()
				require('flash').toggle()
			end,
			desc = 'Toggle Flash Search',
		},
	},
}
