--    ╭────────────────────────────╮
--    │       mini-move.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local move = require('mini.move')

move.setup({
  -- stylua: ignore
  mappings = {
    down       = '<C-down>',
    left       = '<C-left>',
    line_down  = '<C-down>',
    line_left  = '<C-left>',
    line_right = '<C-right>',
    line_up    = '<C-up>',
    right      = '<C-right>',
    up         = '<C-up>',
  },
})
