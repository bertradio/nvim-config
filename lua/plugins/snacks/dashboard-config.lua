-- uses a bash file -- needs to be modified for windows

return {
	'snacks.nvim',
	opts = {
		dashboard = {
			enabled = false,
			width = 45,
			preset = {
				keys = {
					{
						icon = ' ',
						key = 'e',
						desc = 'Explorer',
						action = '<Leader><space>',
					},
					{
						icon = ' ',
						key = 'f',
						desc = 'Find file',
						action = '<Leader>f',
					},
					{
						icon = ' ',
						key = 'r',
						desc = 'Recent',
						action = '<Leader>lo',
					},
					{
						icon = 'y',
						key = 'y',
						desc = 'yazi',
						action = ':lua require("yazi").yazi()',
					},
					{
						icon = 'z',
						key = 'z',
						desc = 'Zoxide',
						action = ':lua Snacks.picker.zoxide()',
					},
					-- {
					--   icon = ' ',
					--   key = 'o',
					--   desc = 'Oil',
					--   action = '-',
					-- },
					{
						icon = '󰒲 ',
						key = 'l',
						desc = 'Lazy',
						action = ':Lazy',
						enabled = package.loaded.lazy ~= nil,
					},
				},
				header = [[]],
			},
			formats = {
				key = function(item)
					return {
						{ '[',      hl = 'special' },
						{ item.key, hl = 'key' },
						{ ']',      hl = 'special' },
					}
				end,
			},
			sections = {
				{ title = "\nIf it ain't broke, don't fix it", align = 'center', padding = 1 },
				{ section = 'recent_files',                    align = 'left',   limit = 10, padding = 1 },
				{ section = 'keys',                            align = 'left',   padding = 1 },
			},
		},
	},

}
