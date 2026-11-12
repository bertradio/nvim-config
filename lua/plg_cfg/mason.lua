--    ╭────────────────────────────╮
--    │         mason.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
--
-- Created: 12/10/23

vim.pack.add({
  Gh('mason-org/mason.nvim'),
})

require('mason').setup()
