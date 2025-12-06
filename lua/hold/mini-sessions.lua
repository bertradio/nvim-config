-- mini-sessions.lua
--
-- Created: 07/21/25

-- Keymaps
-- vim.keymap.set('n', '<Leader>sr', function()
--   require('mini.sessions').read()
-- end, { desc = 'Session: Read' })
vim.keymap.set('n', '<Leader>su', function()
  require('mini.sessions').write()
end, { desc = 'Session update' })
vim.keymap.set('n', '<Leader>ss', function()
  require('mini.sessions').select()
end, { desc = 'Session select' })
vim.keymap.set('n', '<Leader>sn', function()
  local name = vim.fn.input('Session name ')
  if name ~= '' then
    require('mini.sessions').write(name)
  end
end, { desc = 'Session new' })
vim.keymap.set('n', '<Leader>sd', function()
  local name = vim.fn.input('Delete session ')
  if name ~= '' then
    require('mini.sessions').delete(name, { force = true })
  end
end, { desc = 'Session: Delete (force)' })

return {

  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.sessions').setup({
      opts = {
        delete = { force = true },
      },
      autoread = false,
      autowrite = false,
      -- directory = vim.fn.stdpath('data') .. '/sessions',
    })
  end,
}
