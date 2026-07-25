vim.pack.add({ Gh('wsdjeg/iedit.nvim') })

Kset(
  'n',
  '<leader>c',
  "<cmd>lua require('iedit').start()<cr>",
  { silent = true,  desc = 'cursor edit mode'  }
)
