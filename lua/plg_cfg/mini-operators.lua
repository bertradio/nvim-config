--    ╭────────────────────────────╮
--    │     mini-operators.lua     │
--    ╰────────────────────────────╯

-- Created: 08/03/26

local operators = require('mini.operators')

operators.setup({
  -- Each entry configures one operator.
  -- `prefix` defines keys mapped during `setup()`: in Normal mode
  -- to operate on textobject and line, in Visual - on selection.

  -- Evaluate text and replace with output
  evaluate = {
    prefix = 'g=',

    -- Function which does the evaluation
    func = nil,
  },

  -- Exchange text regions
  exchange = {
    -- NOTE: Default `gx` is remapped to `gX`
    prefix = 'gx',

    -- Whether to reindent new text to match previous indent
    reindent_linewise = true,
  },

  -- Multiply (duplicate) text
  multiply = {
    prefix = 'gm',

    -- Function which can modify text before multiplying
    func = nil,
  },

  -- Replace text with register
  replace = {
    -- Preserve Neovim's default `gr*` LSP mappings.
    prefix = 'gR',

    -- Whether to reindent new text to match previous indent
    reindent_linewise = true,
  },

  -- Sort text
  sort = {
    prefix = 'gs',

    -- Function which does the sort
    func = nil,
  },
})
