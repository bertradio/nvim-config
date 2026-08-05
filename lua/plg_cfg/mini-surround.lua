--    ╭────────────────────────────╮
--    │     mini-surround.lua      │
--    ╰────────────────────────────╯

-- 08/01/26 - split from main.lua - changed mappings to start with s instead of gz

local surround = require('mini.surround')

surround.setup({
  -- stylua: ignore
  mappings = {
    add            = '<Leader>sa',     -- Add surround
    delete         = '<Leader>sd',     -- Delete surround
    find           = '<Leader>sf',     -- Find to the right
    find_left      = '<Leader>sF',     -- Find to the left
    highlight      = '<Leader>sh',     -- Highlight surrounding
    replace        = '<Leader>sr',     -- Replace surround
    update_n_lines = '<Leader>sn',     -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})
