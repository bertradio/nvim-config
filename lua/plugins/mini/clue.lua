local miniclue = require('mini.clue')

miniclue.setup({

	window = {
		delay = 500,
		config = {
			width = 'auto',
			border = 'rounded',
		},
		scroll_down = '<Down>',
		scroll_up = '<Up>',
	},

	triggers = {
		{ mode = 'c', keys = '<C-r>' },
		{ mode = 'i', keys = '<C-r>' },
		{ mode = 'i', keys = '<C-x>' },
		{ mode = 'n', keys = "'" },
		{ mode = 'n', keys = '"' },
		{ mode = 'n', keys = '<C-w>' },
		{ mode = 'n', keys = '<Leader>' },
		{ mode = 'n', keys = '`' },
		{ mode = 'n', keys = 'g' },
		{ mode = 'n', keys = 'z' },
		{ mode = 'n', keys = ']' },
		{ mode = 'n', keys = '[' },
		{ mode = 'n', keys = '\\' },
		{ mode = 'x', keys = "'" },
		{ mode = 'x', keys = '"' },
		{ mode = 'x', keys = '<Leader>' },
		{ mode = 'x', keys = '`' },
		{ mode = 'x', keys = 'g' },
		{ mode = 'x', keys = 'z' },
	},

	clues = {

		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),

		{ mode = 'n', keys = '<Leader>b', desc = '+buffer' },
		{ mode = 'n', keys = '<Leader>d', desc = '+diff' },
		{ mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
		{ mode = 'n', keys = '<Leader>f', desc = '+fzf' },
		{ mode = 'n', keys = '<Leader>g', desc = '+goto' },
		-- { mode = 'n', keys = '<Leader>l', desc = '+snacks' },
		{ mode = 'n', keys = '<Leader>m', desc = '+markdown' },

		-- { mode = 'n', keys = '<Leader>a', desc = '+telescope' },
		-- { mode = 'n', keys = '<Leader>c', desc = '+md list change' },
		-- { mode = 'n', keys = '<Leader>h', desc = '+grapple' },
		-- { mode = 'n', keys = '<Leader>n', desc = '+neo-tree' },
		-- { mode = 'n', keys = '<Leader>s', desc = '+sessions' },
		-- { mode = 'n', keys = '<Leader>v', desc = '+fzf' },

	},

})
