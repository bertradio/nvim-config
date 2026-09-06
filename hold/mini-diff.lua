--    ╭────────────────────────────╮
--    │       mini-diff.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local diff = require('mini.diff')

diff.setup({
  source = diff.gen_source.save(),
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '-' },
  },
})
