-- main setup for mini modules

return {
	'nvim-mini/mini.nvim',
	version = false,
	event = 'VeryLazy',
	config = function()
		require('mini.ai').setup()
		require('mini.cmdline').setup()
		require('plugins.mini.align')
		require('plugins.mini.clue')
		require('plugins.mini.comment')
		require('plugins.mini.move')
		require('plugins.mini.surround')
	end,
}
