-- vim-notify.lua

-- Created: 03/09/24

return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    require('notify').setup({
      timeout = 150,
      render = 'compact',
    })
    vim.notify = require('notify')
  end,
}
