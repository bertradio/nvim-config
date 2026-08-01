--    ╭────────────────────────────╮
--    │      mini-notify.lua       │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local notify = require('mini.notify')

notify.setup({
  -- remove time, add space before msg
  content = {
    format = function(notif)
      return ' ' .. tostring(notif.msg)
    end,
  },
  window = {
    config = {
      title = '',
      width = 40,
      border = 'rounded',
    },
  },
})
vim.opt.cmdheight = 0
vim.notify = notify.make_notify({
  INFO = { duration = 2500 }, -- duration 1000 = 1 second
  WARN = { duration = 5000 },
  ERROR = { duration = 8000 },
})
