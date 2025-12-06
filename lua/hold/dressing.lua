-- lua/plugins/dressing.lua
-- for jump menu ("\\")

return {
	'stevearc/dressing.nvim',
	lazy = false,
	opts = {
		select = {
			backend = { 'builtin' }, -- force the builtin floating picker
			builtin = {
				border = 'rounded',
				max_height = 1.0, -- up to 100% of screen height
				min_height = 25, -- never show fewer than 25 rows
			},
			get_config = function(opts)
				if opts.kind == 'cwd_picker' then
					local rows = tonumber(opts.rows) or 10
					return {
						builtin = {
							border = 'rounded',
							max_height = 1.0,
							min_height = math.min(rows + 2, 50), -- expand to show all entries (cap 50)
						},
					}
				end
			end,
		},
	},
}
