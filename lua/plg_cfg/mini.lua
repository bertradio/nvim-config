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
-- 06/01/26 - replaced starter with Snacks.dashboard

vim.pack.add({ Gh('nvim-mini/mini.nvim') })

local ai = require('mini.ai')
local align = require('mini.align')
local bracketed = require('mini.bracketed')
local diff = require('mini.diff')
local move = require('mini.move')
local operators = require('mini.operators')
local pairs = require('mini.pairs')
local surround = require('mini.surround')

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
