-- markview.lua
--
-- Created: 06/29/24

vim.api.nvim_set_keymap(
	'n',
	'<leader>ms',
	'<CMD>Markview splitToggle<CR>',
	{ desc = 'Splitview toggle' }
)

return {
	'OXY2DEV/markview.nvim',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		"saghen/blink.cmp",
		'nvim-tree/nvim-web-devicons', -- Used by the code blocks
	},

	config = function()
		require('markview').setup({
			preview = {
				icon_provider = 'devicons',
			},
		})
	end,
}
