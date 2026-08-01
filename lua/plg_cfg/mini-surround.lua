--    ╭────────────────────────────╮
--    │     mini-surround.lua      │
--    ╰────────────────────────────╯

-- 08/01/26 - split from main.lua

local surround = require('mini.surround')

surround.setup({
  -- stylua: ignore
  mappings = {
    add            = 'gza',     -- Add surround
    delete         = 'gzd',     -- Delete surround
    find           = 'gzf',     -- Find to the right
    find_left      = 'gzF',     -- Find to the left
    highlight      = 'gzh',     -- Highlight surrounding
    replace        = 'gzr',     -- Replace surround
    update_n_lines = 'gzn',     -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})
