--    ╭────────────────────────────╮
--    │       mini-clue.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local clue = require('mini.clue')

clue.setup({

  -- stylua: ignore 
  window = {
    delay  = 500,
    config = {
      width  = 'auto',
      border = 'rounded',
    },
    scroll_down = '<Down>',
    scroll_up   = '<Up>',
  },

  triggers = {
    { mode = 'c', keys = '<C-r>' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'i', keys = '<C-x>' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '"' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = '<Leader>' },
    { mode = 'n', keys = '`' },
    { mode = 'n', keys = 'g' },
    { mode = 'n', keys = 'z' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '"' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'x', keys = '`' },
    { mode = 'x', keys = 'g' },
    { mode = 'x', keys = 'z' },
  },

  clues = {

    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>f', desc = '+fzf' },
    { mode = 'n', keys = '<Leader>m', desc = '+pretty' },
    { mode = 'n', keys = '<Leader>p', desc = '+mini.pick' },
    { mode = 'n', keys = '<Leader>q', desc = '+sessions' },
    { mode = 'n', keys = '<Leader>s', desc = '+mini.surround' },
  },
})
