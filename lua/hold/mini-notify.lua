-- mini-notify.lua
--
-- Created: 08/25/24

return {
  'echasnovski/mini.notify',
  version = false,
  config = function()
    require('mini.notify').setup()
  end,
}
