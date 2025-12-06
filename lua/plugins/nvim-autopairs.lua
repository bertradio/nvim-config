-- auto-pairs.lua
-- better than mini.pairs since it handles quotes before and after text well
-- Created: 03/30/25

return {
	'windwp/nvim-autopairs',
	event  = 'InsertEnter',
	config = function()
		local npairs = require('nvim-autopairs')
		npairs.setup({})
		-- Add custom rules
		local Rule = require('nvim-autopairs.rule')
		npairs.add_rules({
			Rule('<', '>'),
			Rule('*', '*', 'markdown')
		})
	end,
}
