--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from augroups.lua
-- 04/29/26 - add autocmd to delay most require until typing
-- 05/03/26 - configured menu to replace Snacks - code from Gemini - consolidated and tuned shortcuts
-- 05/04/26 - fixed issue with recent not updating by adding rshada! to shortcut

vim.pack.add({ { src = 'http://github.com/nvim-mini/mini.nvim', branch = 'main' } })

-- delay these mappings until new typing
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
        -- Disable and re-enable refreshes the 'save' source baselineS
        require('mini.diff').disable(args.buf)
        require('mini.diff').enable(args.buf)
      end,
    })

    --  ────── end mini.diff setup ───────

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

    require('mini.operators').setup()

    require('mini.pairs').setup({
      mappings = {
        -- pair < >
        ['<'] = { action = 'open', pair = '<>', neigh_pattern = '^[^\\]' },
        ['>'] = { action = 'close', pair = '<>', neigh_pattern = '^[^\\]' },
        -- do not double quote before words
        ["'"] = {
          action = 'closeopen',
          pair = "''",
          neigh_pattern = '[^%w][^%w]',
          register = { cr = false },
        },
        ['"'] = {
          action = 'closeopen',
          pair = '""',
          neigh_pattern = '[^%w][^%w]',
          register = { cr = false },
        },
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

--  ──────────────────── end mini.clue setup ────────────────────

--  ───── ───── mini.starter setup - code from Gemini ───── ─────

local starter = require('mini.starter')

starter.setup({
  auto_setup = false,
  evaluate_single = true,
  query_line_prefix = '',
  show_usage = false,
  footer = function()
    return ''
  end,
  header = "If it ain't broke, don't fix it!",
  items = {
    starter.sections.recent_files(6, false, false),
    {
      name = 'New file',
      action = 'enew | startinsert',
      section = '',
    },
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
    { name = 'Quit Menu', action = 'bwipeout', section = '' },
  },

  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
  silent = true,

  vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' }),
  vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' }),
})

-- open dashboard
local function open_dashboard()
  pcall(function()
    require('mini.starter').open()
    -- Maintain your clean, mid-century modern aesthetic
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' })
    vim.cmd('redraw')
  end)
end

-- open dashboard shortcut
Kset('n', '<space>]', function()
  -- rshada! necessary to make sure recent list is up to date
  vim.cmd('rshada!')
  open_dashboard()
end, { desc = 'Dashboard', silent = true })
