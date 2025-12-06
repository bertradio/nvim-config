-- blink-indent.lua
--
-- Created: 11/07/25
--
-- Using instead of other indent plugin

return {
	'saghen/blink.indent',
	event = 'InsertEnter',
	config = function()
		vim.g.indent_guide = false -- start with guides disabled
		local indent = require('blink.indent')
		vim.keymap.set('n', '<Leader>i', function()
			indent.enable(not indent.is_enabled())
		end, { desc = 'Toggle indent guides' })
		indent.setup({
			scope = {
				-- enable to show underlines on the line above the current scope
				underline = {
					enabled = true,
					-- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
					highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
				}
			}
		})
	end,
}
