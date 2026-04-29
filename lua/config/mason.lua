--    ╭────────────────────────────╮
--    │         mason.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
--
-- Created: 12/10/23

vim.pack.add({
  Gh('williamboman/mason-lspconfig.nvim'),
  Gh('williamboman/mason.nvim'),
})

cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' }
require('mason').setup()
