-- simple screen display
-- for easy reading

-- Myfn.map('n', '<Leader>z', '<cmd>:ZenMode<cr>', { desc = 'ZenMode toggle' })

return {
  'folke/zen-mode.nvim',
  keys = { { '<Leader>z', '<cmd>ZenMode<cr>', desc = 'ZenMode toggle' } },
	-- stylua: ignore
	opts = {
		window = {
			backdrop = 0.5,
			width    = 80,
			height   = 0.85,
			list     = false,
			options  = {
				cursorline   = false, -- turn off hilight of cursor line
				cursorcolumn = false,
			},
		},
		plugins = {
			options = {
				enabled        = true,
				number         = false,
				relativenumber = false,
			},
		},
	} -- end opts
,
}
