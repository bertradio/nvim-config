-- markdown-plus.lua
--
-- Created: 10/23/25
-- For lazy.nvim

return {
	'yousefhadder/markdown-plus.nvim',
	lazy = false,
	ft = { "markdown", "text", "txt" }, -- Match your filetypes config
	config = function()
		require('markdown-plus').setup({
			filetypes = { "markdown", "text", "txt" },
			keymaps = {
				enabled = true, -- Enable default keymaps
			},
		})
	end,
}
