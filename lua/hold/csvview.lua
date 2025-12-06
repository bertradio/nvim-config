-- csvview.lua
--
-- Created: 01/06/25

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

augroup('Enable csvview', { clear = true })
autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter' }, {
	group = 'Enable csvview',
	pattern = { '*.csv' },
	command = 'CsvViewEnable',
})

augroup('Disable csvview', { clear = true })
autocmd({ 'VimLeave', 'WinLeave', 'BufLeave' }, {
	group = 'Disable csvview',
	pattern = { '*.csv' },
	command = 'CsvViewDisable',
})

return {
	'hat0uma/csvview.nvim',
	config = function()
		require('lua.plugins.csvview').setup({
			view = { display_mode = 'border' },
		})
	end,
}
