-- main setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

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

require('mini.comment').setup({
  options = {
    -- Function to compute custom 'commentstring' (optional)
    custom_commentstring = nil,

    -- Whether to ignore blank lines when commenting
    ignore_blank_line = true,

    -- Whether to ignore blank lines in actions and textobject
    start_of_line = false,

    -- Whether to force single space inner padding for comment parts
    pad_comment_parts = true,
  },

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Toggle comment (like `gcip` - comment inner paragraph) for both
    -- Normal and Visual modes
    comment = 'gc',

    -- Toggle comment on current line
    comment_line = 'gcc',

    -- Toggle comment on visual selection
    comment_visual = 'gc',

    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
    -- Works also in Visual mode if mapping differs from `comment_visual`
    textobject = 'gc',
  },

  -- Hook functions to be executed at certain stage of commenting
  hooks = {
    -- Before successful commenting. Does nothing by default.
    pre = function() end,
    -- After successful commenting. Does nothing by default.
    post = function() end,
  },
})
