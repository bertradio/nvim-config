--    ╭────────────────────────────╮
--    │      tiny-cmdline.lua      │
--    ╰────────────────────────────╯

-- Created: 05/03/26

require('vim._core.ui2').enable({})

vim.pack.add({ 'https://github.com/rachartier/tiny-cmdline.nvim' })

vim.o.cmdheight = 0

require('tiny-cmdline').setup({})
