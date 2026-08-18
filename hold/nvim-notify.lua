--    ╭────────────────────────────╮
--    │      nvim-notify.lua       │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26

-- Created: 03/09/24

vim.pack.add({ Gh('rcarriga/nvim-notify') })

require('notify').setup({
  timeout = 150,
  render = 'compact',
  zindex = 2000,
  animation = 'fade_in_slide_out',
})

vim.notify = require('notify')
