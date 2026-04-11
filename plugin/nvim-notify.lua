-- nvim-notify.lua
-- changed from lazy to vim.pack 3-30-26

-- Created: 03/09/24

vim.pack.add({ 'https://github.com/rcarriga/nvim-notify' })

require('notify').setup({
  timeout = 150,
  render = 'compact',
})
vim.notify = require('notify')
