-- select-undo.lua

-- Created: 07/05/26

vim.pack.add({ Gh('SunnyTamang/select-undo.nvim') })

require('select-undo').setup({
  persistent_undo = true, -- Enables persistent undo history (undofile)
  mapping = true, -- Enables default keybindings
  -- mapping = false, -- Enables default keybindings
  line_mapping = 'gu', -- Step: undo the newest change in the selection
  sweep_mapping = 'gU', -- Sweep: undo every selected line's last change
  partial_mapping = 'gC', -- Undo for selected characters
  max_history = 100, -- Undo states searched backward per press
})
