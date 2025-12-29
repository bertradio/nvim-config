-- bullets.lua
-- to handle bulleted lists only in markdown and text files

return {
 	'dkarter/bullets.vim',
	event  = { 'BufReadPre', 'BufNewFile' },
	ft     = { 'markdown', 'text' },

	config = function()
		vim.g.bullets_enabled_file_types = { 'markdown', 'text' }
		-- vim.g.bullets_renumber_on_change = 1
		vim.g.bullets_outline_levels =
		{ 'ROM', 'ABC', 'num', 'abc', 'rom', 'std-', 'std*', 'std+', 'chk' }
	end,
}
