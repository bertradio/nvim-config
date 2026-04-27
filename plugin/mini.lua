--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience

vim.pack.add({ { src = Gh('nvim-mini/mini.nvim'), branch = 'main' } })

require('mini.ai').setup({
  -- disable these so builtin c-space and bs work
  -- for internal visual mode
  mappings = {
    around_next = '',
    inside_next = '',
    around_last = '',
    inside_last = '',
  },
})

require('mini.align').setup({ mappings = { start = 'ga' } })

require('mini.bracketed').setup()

require('mini.jump').setup()

require('mini.jump2d').setup({ -- replaces flash
  view = { dim = true },
})
Snacks.keymap.set(
  'n',
  '<Leader>J',
  '<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
  { desc = 'Jump to character' }
)

require('mini.move').setup({
  -- stylua: ignore 
  mappings = {
    left       = '<C-left>',
    right      = '<C-right>',
    down       = '<C-down>',
    up         = '<C-up>',
    line_left  = '<C-left>',
    line_right = '<C-right>',
    line_down  = '<C-down>',
    line_up    = '<C-up>', },
})

require('mini.pairs').setup()
-- add <> as pair for lua files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    local pairs = require('mini.pairs')
    -- Explicitly map for the current buffer only
    pairs.map_buf(0, 'i', '<', { action = 'open', pair = '< >', neigh_pattern = '[^\\].' })
    pairs.map_buf(0, 'i', '>', { action = 'close', pair = '< >', neigh_pattern = '[^\\].' })
  end,
})

require('mini.surround').setup({
  -- stylua: ignore 
  mappings = {
    add            = 'gza', -- Add surround
    delete         = 'gzd', -- Delete surround
    replace        = 'gzr', -- Replace surround
    find           = 'gzf', -- Find to the right
    find_left      = 'gzF', -- Find to the left
    highlight      = 'gzh', -- Highlight surrounding
    update_n_lines = 'gzn', -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})

--  ──────── mini.clue setup ─────────

local miniclue = require('mini.clue')
miniclue.setup({

  window = {
    delay = 500,
    config = {
      width = 'auto',
      border = 'rounded',
    },
    scroll_down = '<Down>',
    scroll_up = '<Up>',
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
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>s', desc = '+snacks' },
    { mode = 'n', keys = '<Leader>w', desc = '+window' },
  },
})
