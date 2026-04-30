--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from augroups.lua
-- 04/29/26 - add autocmd to delay most require until typing

vim.pack.add({ { src = Gh('nvim-mini/mini.nvim'), branch = 'main' } })

-- delay these until new typing
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile', 'InsertEnter' }, {
  once = true,
  callback = function()
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

    --  ───── mini.diff set up for change signs in gutter ─────

    local diff = require('mini.diff')
    diff.setup({
      source = diff.gen_source.save(),
      view = {
        style = 'sign',
        signs = { add = '+', change = '~', delete = '-' },
      },
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      callback = function(args)
        -- Disable and re-enable refreshes the 'save' source baseline
        require('mini.diff').disable(args.buf)
        require('mini.diff').enable(args.buf)
      end,
    })

    require('mini.jump').setup()

    require('mini.jump2d').setup({ -- replaces flash
      view = { dim = true },
    })
    Snacks.keymap.set(
      'n',
      '<Leader>j',
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
        line_up    = '<C-up>',
      },
    })

  -- stylua: ignore
  require('mini.surround').setup({
    mappings = {
      add            = 'gza',     -- Add surround
      delete         = 'gzd',     -- Delete surround
      replace        = 'gzr',     -- Replace surround
      find           = 'gzf',     -- Find to the right
      find_left      = 'gzF',     -- Find to the left
      highlight      = 'gzh',     -- Highlight surrounding
      update_n_lines = 'gzn',     -- Update n_lines
    },
    n_lines = 50,                 -- search window for surroundings
  })
  end,
})

--  ──────── mini.clue setup ─────────

local miniclue = require('mini.clue')
-- stylua: ignore
miniclue.setup({

  window = {
    delay       = 500,
    config      = {
      width = 'auto',
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
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>s', desc = '+snacks' },
  },
})
