--    ╭────────────────────────────╮
--    │      persistence.lua       │
--    ╰────────────────────────────╯

-- Created: 06/16/26

-- to save and restore sessions

vim.pack.add({ Gh('folke/persistence.nvim') })

local persistence = require('persistence')

persistence.setup({
  dir = vim.fn.stdpath('data') .. '/sessions/', -- directory where session files are saved
  -- minimum number of file buffers that need to be open to save
  -- Set to 0 to always save
  need = 1,
  branch = true, -- use git branch to save session
})

-- load the session for the current directory
vim.keymap.set('n', '<leader>qs', function()
  require('persistence').load()
end, { desc = 'load session - cwd' })

-- select a session to load
vim.keymap.set('n', '<leader>qS', function()
  require('persistence').select()
end, { desc = 'load session - select ' })

-- load the last session
vim.keymap.set('n', '<leader>ql', function()
  require('persistence').load({ last = true })
end, { desc = 'load session - last' })

-- stop Persistence => session won't be saved on exit
vim.keymap.set('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = 'stop persistence' })
