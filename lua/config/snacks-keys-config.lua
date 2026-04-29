--    ╭──────────────────────────────╮
--    │    snacks-keys-config.lua    │
--    ╰──────────────────────────────╯

-- key mappings for snacks

--  ─────────── dashboard ────────────

Myfn.map('n', '<Leader>]', '<cmd>lua Snacks.dashboard.open()<cr>', { desc = 'Open dashboard' })

--  ────────── for deletes ───────────

Myfn.map('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>', { desc = 'delete current' })
Myfn.map('n', '<Leader>bo', '<cmd>lua Snacks.bufdelete.other()<cr>', { desc = 'delete other' })
Myfn.map('n', '<Leader>ba', '<cmd>lua Snacks.bufdelete.all()<cr>', { desc = 'delete all' })

--  ──────────── pickers ─────────────

Myfn.map('n', '<Leader>sb', '<cmd>lua Snacks.picker.buffers()<cr>', { desc = 'buffers' })

Myfn.map(
  'n',
  '<Leader>sd',
  '<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
  { desc = 'diagnostics - buffer' }
)

Myfn.map(
  'n',
  '<Leader>se',
  '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  { desc = 'explorer' }
)

Myfn.map(
  'n',
  '<Leader>x',
  '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  { desc = 'explorer' }
)

--  ───── pickers with cwd displayed - from ChatGPT ─────

Snacks.keymap.set('n', '<Leader>sf', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

Snacks.keymap.set('n', '<Leader><space>', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

--  ───────── other pickers ──────────

Snacks.keymap.set('n', '<Leader>sj', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'jumps',
  })
end, { desc = 'jumps' })

Snacks.keymap.set('n', '<Leader>ss', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'search_history',
  })
end, { desc = 'search history' })

Myfn.map('n', '<Leader>sg', '<cmd>lua Snacks.picker.grep()<cr>', { desc = 'grep' })
Myfn.map('n', '<Leader>sh', '<cmd>lua Snacks.picker.help()<cr>', { desc = 'help' })
Myfn.map(
  'n',
  '<Leader>sk',
  '<cmd>lua Snacks.picker.keymaps({layout = {preview = false}})<cr>',
  { desc = 'keymaps' }
)
Myfn.map('n', '<Leader>sl', '<cmd>lua Snacks.picker.lines()<cr>', { desc = 'buffer lines' })
Myfn.map('n', '<Leader>sm', '<cmd>lua Snacks.picker.marks()<cr>', { desc = 'marks' })
Myfn.map(
  'n',
  '<Leader>sn',
  '<cmd>lua Snacks.picker.notifications()<cr>',
  { desc = 'notifications' }
)
Myfn.map(
  'n',
  '<Leader>so',
  '<cmd>lua Snacks.picker.recent({filter = { cwd = false }})<cr>',
  { desc = 'oldfiles' }
)
Myfn.map('n', '<Leader>sq', '<cmd>lua Snacks.picker.qflist()<cr>', { desc = 'quick fix' })
Myfn.map('n', '<Leader>sr', '<cmd>lua Snacks.picker.registers()<cr>', { desc = 'registers' })
Myfn.map('n', '<Leader>su', '<cmd>lua Snacks.picker.undo()<cr>', { desc = 'undo history' })
Myfn.map('n', '<Leader>sy', '<cmd>lua Snacks.lazygit.open(opts)<cr>', { desc = 'lazygit' })

--  ───── Snacks terminal setup ──────

-- Toggle terminal in a centered floating window
Snacks.keymap.set({ 'n', 't' }, '<Leader>st', function()
  Snacks.terminal.toggle(nil, {
    win = {
      position = 'float',
      border = 'rounded',
      width = 0.9,
      height = 0.9,
    },
  })
end, { desc = 'toggle floating terminal' })

--  ──────────────────────────────────

Myfn.map(
  'n',
  '<Leader>sw',
  '<cmd>lua Snacks.picker.grep_word()<cr>',
  { desc = 'grep selection or word' }
)
Myfn.map('n', '<Leader>sz', '<cmd>lua Snacks.zen()<cr>', { desc = 'zen mode' })
Myfn.map('n', '<Leader>z', '<cmd>lua Snacks.picker.zoxide()<cr>', { desc = 'zoxide' })

-- Spelling picker
Snacks.keymap.set('n', 'zz', function()
  require('snacks').picker.spelling({
    -- layout = 'my_spelling',
  })
end, { desc = 'Spelling Suggestions' })

-- Command picker
Snacks.keymap.set('n', '<Leader>sc', function()
  require('snacks').picker.command_history({
    layout = 'my_keymaps',
    preview = false, -- It doesn't have a preview window in the box, so this is safe
  })
end, { desc = 'cmd history' })

-- Indent toggle
Snacks.keymap.set('n', '<leader>si', function()
  if Snacks.indent.enabled then
    Snacks.indent.disable()
  else
    Snacks.indent.enable()
  end
end, { desc = 'Toggle indent Guides' })
