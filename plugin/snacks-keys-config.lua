--    ╭───────────────────────────────╮
--    │    key mappings for snacks    │
--    ╰───────────────────────────────╯

-- dashboard
Myfn.map('n', '<Leader>]', '<cmd>lua Snacks.dashboard.open()<cr>', { desc = 'Open dashboard' })

-- -- for deletes
Myfn.map('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>', { desc = 'delete current' })
Myfn.map('n', '<Leader>bo', '<cmd>lua Snacks.bufdelete.other()<cr>', { desc = 'delete other' })
Myfn.map('n', '<Leader>ba', '<cmd>lua Snacks.bufdelete.all()<cr>', { desc = 'delete all' })

Myfn.map('n', '<Leader>lb', '<cmd>lua Snacks.picker.buffers()<cr>', { desc = 'buffers' })

Myfn.map(
  'n',
  '<Leader>ld',
  '<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
  { desc = 'diagnostics - buffer' }
)

Myfn.map(
  'n',
  '<Leader>x',
  -- '<Leader><space>',
  '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  { desc = 'explorer' }
)

-- pickers with cwd displayed - from ChatGPT
vim.keymap.set('n', '<Leader>lf', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    layout = 'my_default',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

vim.keymap.set('n', '<Leader><space>', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    layout = 'my_default',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

vim.keymap.set('n', '<Leader>lj', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'jumps',
    -- layout = 'my_default',
  })
end, { desc = 'jumps' })

vim.keymap.set('n', '<Leader>ls', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'smart',
    -- layout = 'my_default',
    title = Myfn.short_cwd(),
  })
end, { desc = 'smart with cwd' })

Myfn.map('n', '<Leader>lg', '<cmd>lua Snacks.picker.grep()<cr>', { desc = 'grep' })
Myfn.map('n', '<Leader>lh', '<cmd>lua Snacks.picker.help()<cr>', { desc = 'help' })
-- Myfn.map('n', '<Leader>lj', '<cmd>lua Snacks.picker.jumps()<cr>', { desc = 'jumps' })
Myfn.map(
  'n',
  '<Leader>lk',
  '<cmd>lua Snacks.picker.keymaps({layout = {preview = false}})<cr>',
  { desc = 'keymaps' }
)
Myfn.map('n', '<Leader>ll', '<cmd>lua Snacks.picker.lines()<cr>', { desc = 'buffer lines' })
Myfn.map('n', '<Leader>lm', '<cmd>lua Snacks.picker.marks()<cr>', { desc = 'marks' })
Myfn.map(
  'n',
  '<Leader>ln',
  '<cmd>lua Snacks.picker.notifications()<cr>',
  { desc = 'notifications' }
)
Myfn.map(
  'n',
  '<Leader>lo',
  '<cmd>lua Snacks.picker.recent({filter = { cwd = false }})<cr>',
  -- filter does not take project into account and just shows same as telescope
  { desc = 'oldfiles' }
)
Myfn.map('n', '<Leader>lq', '<cmd>lua Snacks.picker.qflist()<cr>', { desc = 'quick fix' })
Myfn.map('n', '<Leader>lr', '<cmd>lua Snacks.picker.registers()<cr>', { desc = 'registers' })
Myfn.map('n', '<Leader>lt', '<cmd>lua Snacks.lazygit.open(opts)<cr>', { desc = 'lazygit' })
Myfn.map('n', '<Leader>lu', '<cmd>lua Snacks.picker.undo()<cr>', { desc = 'undo history' })
Myfn.map('n', '<Leader>ly', '<cmd>lua Snacks.picker.lsp_symbols()<cr>', { desc = 'lsp symbols' })
Myfn.map(
  'n',
  '<Leader>lw',
  '<cmd>lua Snacks.picker.grep_word()<cr>',
  { desc = 'grep selection or word' }
)
Myfn.map('n', '<Leader>lz', '<cmd>lua Snacks.zen()<cr>', { desc = 'zen mode' })
Myfn.map('n', '<Leader>z', '<cmd>lua Snacks.picker.zoxide()<cr>', { desc = 'zoxide' })

-- Spelling picker
vim.keymap.set('n', 'zz', function()
  require('snacks').picker.spelling({
    layout = 'my_spelling',
  })
end, { desc = 'Spelling Suggestions' })

-- Command picker
vim.keymap.set('n', '<Leader>lc', function()
  require('snacks').picker.command_history({
    layout = 'my_keymaps',
    preview = false, -- It doesn't have a preview window in the box, so this is safe
  })
end, { desc = 'cmd history' })
