-- livepreview.lua

-- Created: 09/27/26

vim.pack.add({ Gh('brianhuster/live-preview.nvim'), Gh('nvim-mini/mini.nvim') })

require('livepreview.config').set({
  port = 5500,
  browser = 'chromium',
  dynamic_root = true,
  sync_scroll = true,
  picker = 'mini.pick',
  address = '127.0.0.1',
})

Kset('n', '<Leader>ls', '<cmd>LivePreview start<cr>', { desc = 'start' })
Kset('n', '<Leader>lc', '<cmd>LivePreview close<cr>', { desc = 'close' })
Kset('n', '<Leader>lp', '<cmd>LivePreview pick<cr>', { desc = 'pick' })
