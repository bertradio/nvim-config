-- to permit editing of markdown tables
-- toggle with :Mtm

return {
	'Kicamon/markdown-table-mode.nvim',
	event = { 'BufReadPre', 'BufNewFile' },
	keys = {
		{ '<Leader>mt', '<cmd>Mtm<cr>', desc = 'Table toggle' },
	},
	config = function()
		require('markdown-table-mode').setup({
			filetype = {
				'*.md',
			},
			options = {
				insert = true,         -- when typing "|"
				insert_leave = true,   -- when leaving insert
				pad_separator_line = true, -- add space in separator line
				alig_style = 'default', -- default, left, center, right
			},
		})
	end,
}
