-- nvim-notify.lua

-- Created: 03/09/24

vim.pack.add({ 'https://github.com/rcarriga/nvim-notify' })
require('notify').setup({
  timeout = 150,
  render = 'compact',
})
vim.notify = require('notify')
