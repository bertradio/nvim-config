-- mini-sessions.lua

-- Created: 08/08/26

local sessions = require('mini.sessions')

sessions.setup({
  autoread = false,
  autowrite = false,
})

-- Choose and open a session
Kset('n', '<Leader>Qs', function()
  sessions.select('read')
end, { desc = 'select session' })

-- Save/update the currently active session
Kset('n', '<Leader>Qw', function()
  sessions.write()
end, { desc = 'write current session' })

-- Create/update Session.vim in the current directory
Kset('n', '<Leader>Ql', function()
  sessions.write('Session.vim')
end, { desc = 'write local session' })

-- Create a named global session
Kset('n', '<Leader>Qn', function()
  vim.ui.input({ prompt = 'Session name: ' }, function(name)
    if not name or name == '' then
      return
    end

    sessions.write(name .. '.vim')
  end)
end, { desc = 'new named session' })

-- Choose a session to delete
Kset('n', '<Leader>Qd', function()
  sessions.select('delete', { force = true })
end, { desc = 'delete session' })

-- Restart Neovim and restore the current session
Kset('n', '<Leader>Qr', function()
  sessions.restart()
end, { desc = 'restart with session' })
