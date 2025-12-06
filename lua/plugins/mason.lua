-- lspconfig.lua
--
-- Created: 12/10/23

return {
	'williamboman/mason.nvim',

	cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
	config = function()
		require('mason').setup()
	end,
}
