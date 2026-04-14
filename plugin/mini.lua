--    ╭───────────────────────────────────╮
--    │    main setup for mini modules    │
--    ╰───────────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience since small

vim.pack.add({ Gh('nvim-mini/mini.nvim') })

require('mini.ai').setup()

require('mini.align').setup({ mappings = { start = 'ga' } })

require('mini.surround').setup({
  mappings = {
    add = 'gza', -- Add surround
    delete = 'gzd', -- Delete surround
    replace = 'gzr', -- Replace surround
    find = 'gzf', -- Find to the right
    find_left = 'gzF', -- Find to the left
    highlight = 'gzh', -- Highlight surrounding
    update_n_lines = 'gzn', -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})

require('mini.move').setup({
  mappings = {
    left = '<C-left>',
    right = '<C-right>',
    down = '<C-down>',
    up = '<C-up>',
    line_left = '<C-left>',
    line_right = '<C-right>',
    line_down = '<C-down>',
    line_up = '<C-up>',
  },
})
