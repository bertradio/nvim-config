--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from augroups.lua
-- 04/29/26 - add autocmd to delay most require until typing
-- 05/03/26 - configured menu to replace Snacks - code from Gemini - consolidated and tuned shortcuts

vim.pack.add({ { src = 'http://github.com/nvim-mini/mini.nvim', branch = 'main' } })

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
    Kset(
      'n',
      '<Leader>j',
      '<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
      { desc = 'Jump to character' }
    )

    require('mini.indentscope').setup()

    -- stylua: ignore
    require('mini.move').setup({
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

    { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+Edit configs' },
    { mode = 'n', keys = '<Leader>f', desc = '+Fzf' },
    { mode = 'n', keys = '<Leader>s', desc = '+Snacks' },
  },
})

--  ──────── mini.starter setup ─────────

local starter = require('mini.starter')

local function open_dashboard()
  -- Use pcall to ensure it doesn't crash if called too early
  pcall(function()
    vim.cmd('silent! lua MiniStarter.open()')
    -- FORCE UI HIDING: Apply these every time it opens
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' })
    vim.cmd('redraw')
  end)
end

starter.setup({
  auto_setup = true,
  show_usage = false,
  query_line_prefix = '',
  footer = function()
    return ''
  end,
  header = "If it ain't broke, don't fix it!",
  items = {
    starter.sections.recent_files(5, false),
    {
      name = 'Find Files',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>ff', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Grep',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>fg', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Jumps',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>fj', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Recent Files',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>fr', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Zoxide',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>z', true, true, true))
      end,
      section = '',
    },
    { name = 'Close Menu', action = 'bwipeout', section = '' },
  },
  content_hooks = {
    starter.gen_hook.adding_bullet('░ '),
    starter.gen_hook.aligning('center', 'center'),
  },
  silent = true,
})

vim.keymap.set('n', '<space>]', open_dashboard, { desc = 'Dashboard', silent = true })

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
      open_dashboard()
    end
  end,
})

-- This autocmd forces the dashboard to hide the query line text every time it gains focus
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'starter',
  callback = function()
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' })
    -- Force 'q' and 'esc' for this buffer
    local opts = { buffer = true, silent = true }
    vim.keymap.set('n', 'q', '<cmd>bwipeout<cr>', opts)
    vim.keymap.set('n', '<esc>', '<cmd>bwipeout<cr>', opts)
  end,
})
