-- main setup for mini modules

return {
	'nvim-mini/mini.nvim',
	version = false,
	event = 'VeryLazy',
	config = function()
		require('mini.ai').setup()
		require('mini.align').setup({ mappings = { start = 'ga' } })
		require('plugins.mini.clue')
		require('plugins.mini.comment')
		require('plugins.mini.move')
		require('plugins.mini.surround')
	end,
}
