-- bafa.lua
--
-- Created: 12/20/25

return {
	-- Buffer management
	'mistweaverco/bafa.nvim',
	opts = {
		width = 60,
		height = 10,
		title = "Bafa",
		title_pos = "center",
		relative = "editor",
		border = "rounded",
		style = "minimal",
		diagnostics = true,
		-- or "ErrorMsg", "WarningMsg", etc. -- Falls back to WarningMsg if the specified highlight group doesn't exist
		modified_hl = "DiffChanged",
	}
}
