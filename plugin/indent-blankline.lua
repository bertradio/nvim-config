-- indent-blankline.lua

-- Created: 10/30/23

-- To show colored bars for indents
Myfn.map('n', '<Leader>i', '<cmd>IBLToggle<cr>', { desc = 'Indent lines toggle' })

vim.pack.add({ { src = Gh('lukas-reineke/indent-blankline.nvim'), main = 'ibl' } })

-- sets the order of colors on the indent markers
local highlight = {
  'RainbowBlue',
  'RainbowOrange',
  'RainbowCyan',
  'RainbowRed',
  'RainbowGreen',
  'RainbowViolet',
  'RainbowYellow',
}

-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
local hooks = require('ibl.hooks')
		--stylua: ignore
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
			vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
			vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
			vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
			vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
			vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
			vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
		end
		)

require('ibl').setup({
  -- need to disable on start so that first toggle turns it on
  enabled = false,
  indent = { highlight = highlight },
})
