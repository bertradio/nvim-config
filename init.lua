--    ╭────────────────────────────╮
--    │          init.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- moved all setting to settings.lua 4/10/26 - only requires here
-- also move all adds to individual files

-- need to load snacks early so Snacks.keymap works in config files
vim.pack.add({ { src = 'http://github.com/folke/snacks.nvim' } })
require('snacks')

-- initialization file
require('settings')
