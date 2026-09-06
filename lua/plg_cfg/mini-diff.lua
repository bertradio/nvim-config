-- mini-diff.lua

-- Created: 09/06/26

local diff = require('mini.diff')

-- Diff with last saved version
diff.setup({
  -- source = diff.gen_source.save(),
  view = {
    style = 'sign',
    signs = {
      add = '+',
      change = '-',
      delete = 'x',
    },
  },
})

-- Keymaps
Kset('n', '<Leader>do', '<cmd>lua MiniDiff.toggle_overlay()<cr>', { desc = 'diff overlay' })
