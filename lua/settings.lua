--    ╭────────────────────────────╮
--    │        settings.lua        │
--    ╰────────────────────────────╯

-- Optimized for Neovim 0.12
-- General settings and global logic
-- From Gemini. Options moved to options.lua
-- 04/30/26 moved keymaps and aucmds to plugin_setup.lua to load on UI entry

-- 1. PERFORMANCE FIRST
if vim.loader then
  vim.loader.enable()
end

-- 2. LEADERS (Must be set before plugins/keymaps)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Consistent border highlights
vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'Title' })
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })

-- 3. LOAD MODULAR SETTINGS OPTIONS
require('options').setup()

-- 4. DIRECTORY & BINARY LOGIC
do
  local data_dir = vim.fn.stdpath('data')
  vim.fn.mkdir(data_dir .. '/undo', 'p')
  vim.fn.mkdir(data_dir .. '/backup', 'p')
end

Myfn = require('my_fns') -- make my functions accessible

-- shortcut for simpler vim.pack.add to insert github.com
Gh = function(x)
  return 'https://github.com/' .. x
end
