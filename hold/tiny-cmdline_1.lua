--    ╭────────────────────────────╮
--    │      tiny-cmdline.lua      │
--    ╰────────────────────────────╯

-- Created: 05/03/26

require('vim._core.ui2').enable({})

vim.pack.add({ 'https://github.com/rachartier/tiny-cmdline.nvim' })

vim.o.cmdheight = 0

vim.api.nvim_set_hl(0, 'TinyCmdlineBorder', { fg = '#FFA500' })
vim.api.nvim_set_hl(0, 'TinyCmdlineNormal', { bg = 'none' })

require('tiny-cmdline').setup({
  native_types = {}, -- use for search too
  on_reposition = require('tiny-cmdline').adapters.blink,
})
