-- init.lua
-- changed from lazy to vim.pack 3-30-26
-- moved all setting to settings.lua 4/10/26 - only requires here
-- also move all adds to individual files

-- my requires

-- make my functions accessible
Myfn = require('my_fns')

-- initialization files
require('augroups')
require('keymaps')
require('settings')
