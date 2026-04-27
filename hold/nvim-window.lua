-- nvim-window.lua
--
-- Created: 04/26/26

-- Jumpe easily between windows
vim.pack.add({ Gh('yorickpeterse/nvim-window') })

Snacks.keymap.set(
  'n',
  '<Leader>wj',
  "<cmd>lua require('nvim-window').pick()<cr>",
  { desc = 'Jump to window' }
)
