--    ╭────────────────────────────╮
--    │       mini-pairs.lua       │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local mpairs = require('mini.pairs')

mpairs.setup({
  -- add <> as pair
  -- config so ' before a word does not get peired
  mappings = {
    -- pair < >
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '^[^\\]' },
    ['>'] = { action = 'close', pair = '<>', neigh_pattern = '^[^\\]' },
    -- do not double quote before words
    ["'"] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = "''",
      register = { cr = false },
    },
    ['"'] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = '""',
      register = { cr = false },
    },
  },
})
