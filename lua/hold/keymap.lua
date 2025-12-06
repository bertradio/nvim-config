-- lua/plugins/mini-keymap.lua
return {
  {
    'nvim-mini/mini.nvim',
    -- version = '*',
    -- event = 'VeryLazy',
    config = function()
      -- Make multi-key chords reliable
      vim.o.timeout = true
      vim.o.timeoutlen = 300 -- try 200–400ms; raise if you type a bit slower

      local keymap = require('mini.keymap')
      keymap.setup()

      -- Use the correct interface:
      local mm = keymap.map_multistep

      -- Only what you asked for:
      mm.i('jk', '<Esc>', { desc = 'Exit insert with jk' })
      mm.i('kj', '<Esc>', { desc = 'Exit insert with kj' })
    end,
  },
}
