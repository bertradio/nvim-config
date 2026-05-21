--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from aucmds.lua
-- 04/29/26 - add autocmd to delay most require until typing
-- 05/03/26 - configured menu to replace Snacks - code from Gemini - consolidated and tuned shortcuts
-- 05/04/26 - fixed issue with recent not updating by adding rshada! to shortcut
-- 05/08/26 - cleaned up and optimized starter
-- 05/20/26 - added local requires

vim.pack.add({ { src = Gh('nvim-mini/mini.nvim'), branch = 'main' } })

local ai = require('mini.ai')
local align = require('mini.align')
local bracketed = require('mini.bracketed')
local diff = require('mini.diff')
local move = require('mini.move')
local operators = require('mini.operators')
local pairs = require('mini.pairs')
local surround = require('mini.surround')
local starter = require('mini.starter')

-- delay some mini.ai mapping
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile', 'InsertEnter' }, {
  once = true,
  callback = function()
    ai.setup({
      -- disable these so builtin c-space and bs work
      -- for internal visual mode
      mappings = {
        around_next = '',
        inside_next = '',
        around_last = '',
        inside_last = '',
      },
    })
  end,
})

align.setup({ mappings = { start = 'ga' } })

bracketed.setup()

--  ───── mini.diff set up for change signs in gutter ─────

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
    diff.disable(args.buf)
    diff.enable(args.buf)
  end,
})

--  ────── end mini.diff setup ───────

-- stylua: ignore
move.setup({
  mappings = {
    down       = '<C-down>',
    left       = '<C-left>',
    line_down  = '<C-down>',
    line_left  = '<C-left>',
    line_right = '<C-right>',
    line_up    = '<C-up>',
    right      = '<C-right>',
    up         = '<C-up>',
  },
})

operators.setup()

-- add <> as pair
-- config so ' before a word does not get peired
pairs.setup({
  mappings = {
    -- pair < >
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '^[^\\]' },
    ['>'] = { action = 'close', pair = '<>', neigh_pattern = '^[^\\]' },
    -- do not double quote before words
    ["'"] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = "''",
      register = { cr = false },
    },
    ['"'] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = '""',
      register = { cr = false },
    },
  },
})

-- stylua: ignore
surround.setup({
  mappings = {
    add            = 'gza',     -- Add surround
    delete         = 'gzd',     -- Delete surround
    find           = 'gzf',     -- Find to the right
    find_left      = 'gzF',     -- Find to the left
    highlight      = 'gzh',     -- Highlight surrounding
    replace        = 'gzr',     -- Replace surround
    update_n_lines = 'gzn',     -- Update n_lines
  },
  n_lines = 50,                 -- search window for surroundings
})

--  ───── ───── ───── mini.starter setup - code from Gemini ───── ───── ─────

local num_of_recent = 6 -- number of recent files to display

-- stylua: ignore 
starter.setup({
  autoopen          = false,
  auto_setup        = false,
  evaluate_single   = true,
  query_line_prefix = '',
  show_usage        = false,

  header = "If it ain't broke, don't fix it!",
  footer = function()
    return ''
  end,

  items = {
    starter.sections.recent_files(num_of_recent, false, false),
    -- {
    --   name = 'Explorer',
    --   action = function()
    --     vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>x', true, true, true))
    --   end,
    --   section = '',
    -- },
    {
      name = 'Find Files',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sf', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Grep',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sg', true, true, true))
      end,
      section = '',
    },
    {
      name = 'New file',
      action = 'enew',
      section = '',
    },
    {
      name = 'Recent Files',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sr', true, true, true))
      end,
      section = '',
    },
    {
      name = 'Yazi',
      action = function()
        vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>y', true, true, true))
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
})

-- open dashboard
local function open_dashboard()
  pcall(function()
    starter.open()
    -- Maintain your clean, mid-century modern aesthetic
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' })
    vim.cmd('redraw')
  end)
end

-- open dashboard shortcut - force reread of saved data
Kset('n', '<space>]', function()
  -- rshada! necessary to make sure recent list is up to date
  vim.cmd('rshada!')
  open_dashboard()
end, { desc = 'Dashboard', silent = true })
