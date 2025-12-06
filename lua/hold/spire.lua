-- spire.lua
--
-- Created: 10/07/25

return {
 'spiperac/spire.nvim',

		config = function() 
			require("spire").setup({
				prompt_location = "bottom",
				icons = {
					provider = 'mini'
				},
				files = {
					mappings = {
						open_vsplit = '<C-s>'
					}
				},
				grep = {
					hidden_files = true,
				}
			})

			-- Plugin Key Mappings
			local map = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }

			map("n", "<leader>sf", ':SpireFiles<CR>', vim.tbl_extend("force", opts, { desc = "Spire Files" }))
			map("n", "<leader>sb", ':SpireBuffers<CR>', vim.tbl_extend("force", opts, { desc = "Spire Buffers" }))
			map("n", "<leader>sg", ':SpireGrep<CR>', vim.tbl_extend("force", opts, { desc = "Spire Grep Search" }))
	end
}

