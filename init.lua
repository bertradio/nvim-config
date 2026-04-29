--    ╭────────────────────────────╮
--    │          init.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- moved all setting to settings.lua 4/10/26 - only requires here
-- also move all adds to individual file and lazy loadedi with plugin_setup

-- initialization file
require('plugin_setup') -- autocmds to set order of lazy loading
require('settings')
