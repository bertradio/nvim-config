--    ╭────────────────────────────╮
--    │        settings.lua        │
--    ╰────────────────────────────╯

-- Optimized for Neovim 0.12
-- General settings and global logic
-- From Gemini. Options moved to options.lua
-- 04/30/26 moved keymaps and aucmds to plugin_setup.lua to load on UI entry

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options').setup()

do
  local data_dir = vim.fn.stdpath('data')
  vim.fn.mkdir(data_dir .. '/undo', 'p')
  vim.fn.mkdir(data_dir .. '/backup', 'p')
end

Myfn = require('my_fns') -- make my functions accessible

vim.api.nvim_set_hl(0, 'SpellBad', { fg = '#ffffff', bg = '#EB727E' })
