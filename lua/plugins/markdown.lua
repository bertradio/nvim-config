-- markdown.lua
--
-- Created: 03/21/24

return {

	'MeanderingProgrammer/markdown.nvim',
	name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
	-- dependencies = { 'nvim-treesitter/nvim-treesitter' },
	event = { 'BufReadPre', 'BufNewFile' },
	config = function()
		require('render-markdown').setup({
			latex = { enabled = false },
			html = { enabled = false },
			yaml = { enabled = false },
			completions = { lsp = { enabled = true } },
		})
	end,
}
