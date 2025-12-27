-- key mappings for snacks

-- dashboard
Myfn.map('n', '<Leader>]', '<cmd>lua Snacks.dashboard.open()<cr>', { desc = 'Open dashboard' })

-- pickers

-- Myfn.map('n', '<Leader>lb', '<cmd>lua Snacks.picker.buffers()<cr>', { desc = 'buffers' })
-- Myfn.map(
-- 	'n',
-- 	'<Leader>lc',
-- 	'<cmd>lua Snacks.picker.command_history()<cr>',
-- 	{ desc = 'cmd history' }
-- )

-- Myfn.map(
-- 	'n',
-- 	'<Leader>ld',
-- 	'<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
-- 	{ desc = 'diagnostics - buffer' }
-- )

Myfn.map(
	'n',
	'<Leader>x',
	-- '<Leader><space>',
	'<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
	{ desc = 'explorer' }
)

-- -- pickers with cwd displayed - from ChatGPT
-- vim.keymap.set('n', '<Leader>lf', function()
-- 	local snacks = require('snacks')
-- 	snacks.picker({
-- 		source = 'files',
-- 		layout = 'my_default',
-- 		title = Myfn.short_cwd(),
-- 	})
-- end, { desc = 'files cwd' })

-- vim.keymap.set('n', '<Leader>lj', function()
-- 	local snacks = require('snacks')
-- 	snacks.picker({
-- 		source = 'jumps',
-- 		layout = 'my_default',
-- 	})
-- end, { desc = 'jumps' })

-- vim.keymap.set('n', '<Leader>ls', function()
-- 	local snacks = require('snacks')
-- 	snacks.picker({
-- 		source = 'smart',
-- 		layout = 'my_default',
-- 		title = Myfn.short_cwd(),
-- 	})
-- end, { desc = 'smart with cwd' })

-- Myfn.map('n', '<Leader>lg', '<cmd>lua Snacks.picker.grep()<cr>', { desc = 'grep' })
-- Myfn.map('n', '<Leader>lh', '<cmd>lua Snacks.picker.help()<cr>', { desc = 'help' })
-- -- Myfn.map('n', '<Leader>lj', '<cmd>lua Snacks.picker.jumps()<cr>', { desc = 'jumps' })
-- Myfn.map('n', '<Leader>lk', '<cmd>lua Snacks.picker.keymaps()<cr>', { desc = 'keymaps' })
-- Myfn.map('n', '<Leader>ll', '<cmd>lua Snacks.picker.lines()<cr>', { desc = 'buffer lines' })
-- Myfn.map('n', '<Leader>lm', '<cmd>lua Snacks.picker.marks()<cr>', { desc = 'marks' })
-- Myfn.map(
-- 	'n',
-- 	'<Leader>ln',
-- 	'<cmd>lua Snacks.picker.notifications()<cr>',
-- 	{ desc = 'notifications' }
-- )
-- Myfn.map('n', '<Leader>lo', '<cmd>lua Snacks.picker.recent()<cr>', { desc = 'oldfiles' })
-- Myfn.map('n', '<Leader>lq', '<cmd>lua Snacks.picker.qflist()<cr>', { desc = 'quick fix' })
-- Myfn.map('n', '<Leader>lr', '<cmd>lua Snacks.picker.registers()<cr>', { desc = 'registers' })
-- Myfn.map('n', '<Leader>lt', '<cmd>lua Snacks.terminal()<cr>', { desc = 'terminal' })
-- Myfn.map('n', '<Leader>lu', '<cmd>lua Snacks.picker.undo()<cr>', { desc = 'undo history' })
-- Myfn.map('n', '<Leader>ly', '<cmd>lua Snacks.picker.lsp_symbols()<cr>', { desc = 'lsp symbols' })
-- Myfn.map(
-- 	'n',
-- 	'<Leader>lw',
-- 	'<cmd>lua Snacks.picker.grep_word()<cr>',
-- 	{ desc = 'grep selection or word' }
-- )
-- Myfn.map('n', '<Leader>lz', '<cmd>lua Snacks.picker.zoxide()<cr>', { desc = 'zoxide' })
-- -- Myfn.map('n', '<Leader>lz', '<cmd>lua Snacks.zen()<cr>', { desc = 'zen mode' })

-- for deletes
Myfn.map('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>', { desc = 'delete current' })
Myfn.map('n', '<Leader>bo', '<cmd>lua Snacks.bufdelete.other()<cr>', { desc = 'delete other' })
Myfn.map('n', '<Leader>ba', '<cmd>lua Snacks.bufdelete.all()<cr>', { desc = 'delete all' })

return {
	'snacks.nvim',
	keys = { -- use snacks for spelling correction suggestions
		{
			'zz',
			function()
				if vim.v.count == 0 then
					Snacks.picker.spelling()
				else
					vim.cmd('normal! ' .. vim.v.count .. 'z=')
				end
			end,
			desc = 'Spelling Suggestions',
		},
	},
}
