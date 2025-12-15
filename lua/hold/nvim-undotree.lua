-- undotree.lua
--
-- Created: 12/13/25

return {
	"jiaoshijie/undotree",

	opts = {},
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
	},
}
