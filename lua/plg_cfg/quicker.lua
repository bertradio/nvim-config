--    ╭────────────────────────────╮
--    │        quicker.lua         │
--    ╰────────────────────────────╯

-- Created: 07/08/26

-- Powerful editor etc for quickfix - details at website

vim.pack.add({ Gh('stevearc/quicker.nvim') })

require('quicker').setup({
  Kset('n', '<leader>qt', function()
    require('quicker').toggle()
  end, {
    desc = 'Toggle quickfix',
  }),
  Kset('n', '<leader>ql', function()
    require('quicker').toggle({ loclist = true })
  end, {
    desc = 'Toggle loclist',
  }),

  keys = {
    {
      '>',
      function()
        require('quicker').expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = 'Expand quickfix context',
    },
    {
      '<',
      function()
        require('quicker').collapse()
      end,
      desc = 'Collapse quickfix context',
    },
  },
})
