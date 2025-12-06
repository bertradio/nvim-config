-- artio.lua
--
-- Created: 11/17/25

return {
	"comfysage/artio.nvim",
	lazy = false,

	config = function()
		require("artio").setup({
			opts = {
				preselect = true,
				bottom = true,
				promptprefix = "",
				pointer = "",
			},
			win = {
				height = 12,
				hidestatusline = false, -- works best with laststatus=3
			},
		})

		-- override built-in ui select with artio
		vim.ui.select = require("artio").select
		vim.keymap.set("n", "<leader>af", '<cmd>artio-files<cr>')
	end
}
