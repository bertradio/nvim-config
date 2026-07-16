--    ╭────────────────────────────╮
--    │          init.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- moved all setting to settings.lua 4/10/26 - only requires here
-- also move all adds to individual file and lazy loadedi with plugin_setup
-- 05/03/26 - added code to configure MiniStarter
-- 07/12/26 - removed code for mini,starter since not used

-- for all keymaps
Kset = vim.keymap.set

-- no splash screen
vim.opt.shortmess:append('I')

-- initialization files
require('settings') -- calls options.lua
require('plugin_setup') -- autocmds to set order of lazy loading
