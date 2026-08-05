--    ╭────────────────────────────╮
--    │        mini-ai.lua         │
--    ╰────────────────────────────╯

-- 08/01/26 -- config for mini.ai split from mini

vim.pack.add({
  {
    src = Gh('nvim-treesitter/nvim-treesitter-textobjects'),
    version = 'main',
  },
})

local ai = require('mini.ai')

-- ───── mini.ai text objects ─────

local ts_textobject = ai.gen_spec.treesitter

ai.setup({
  n_lines = 500,

  custom_textobjects = {
    -- Function
    F = ts_textobject({
      a = '@function.outer',
      i = '@function.inner',
    }),

    -- Function call
    c = ts_textobject({
      a = '@call.outer',
      i = '@call.inner',
    }),

    -- Argument or parameter
    a = ts_textobject({
      a = '@parameter.outer',
      i = '@parameter.inner',
    }),

    -- Conditional or loop
    o = ts_textobject({
      a = {
        '@conditional.outer',
        '@loop.outer',
      },
      i = {
        '@conditional.inner',
        '@loop.inner',
      },
    }),

    -- Assignment
    A = ts_textobject({
      a = '@assignment.outer',
      i = {
        '@assignment.lhs',
        '@assignment.rhs',
      },
    }),

    -- Comment
    C = ts_textobject({
      a = '@comment.outer',
      i = '@comment.inner',
    }),
  },

  mappings = {
    around = 'a',
    inside = 'i',

    around_next = 'an',
    inside_next = 'in',

    around_last = 'al',
    inside_last = 'il',

    goto_left = 'g[',
    goto_right = 'g]',
  },

  search_method = 'cover_or_next',
  silent = false,
})
