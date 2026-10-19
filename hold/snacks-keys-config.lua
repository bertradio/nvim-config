--    ╭──────────────────────────────╮
--    │    snacks-keys-config.lua    │
--    ╰──────────────────────────────╯

-- key mappings for snacks

local kset = vim.keymap.set

--  ─────────── dashboard ────────────

kset('n', '<Leader>]', '<cmd>lua Snacks.dashboard.open()<cr>', { desc = 'Open dashboard' })

--  ────────── for deletes ───────────

kset('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>', { desc = 'delete current' })
kset('n', '<Leader>bo', '<cmd>lua Snacks.bufdelete.other()<cr>', { desc = 'delete other' })
kset('n', '<Leader>ba', '<cmd>lua Snacks.bufdelete.all()<cr>', { desc = 'delete all' })

--  ──────────── pickers ─────────────

kset('n', '<Leader>sb', '<cmd>lua Snacks.picker.buffers()<cr>', { desc = 'buffers' })

kset(
  'n',
  '<Leader>sd',
  '<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
  { desc = 'diagnostics - buffer' }
)

kset(
  'n',
  '<Leader>se',
  '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  { desc = 'explorer' }
)

kset(
  'n',
  '<Leader>x',
  '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  { desc = 'explorer' }
)

--  ───── pickers with cwd displayed - from ChatGPT ─────

kset('n', '<Leader>sf', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

kset('n', '<Leader><space>', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })

--  ───────── other pickers ──────────

kset('n', '<Leader>sj', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'jumps',
  })
end, { desc = 'jumps' })

kset('n', '<Leader>ss', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'search_history',
  })
end, { desc = 'search history' })

kset('n', '<Leader>sg', '<cmd>lua Snacks.picker.grep()<cr>', { desc = 'grep' })
kset('n', '<Leader>sh', '<cmd>lua Snacks.picker.help()<cr>', { desc = 'help' })
kset(
  'n',
  '<Leader>sk',
  '<cmd>lua Snacks.picker.keymaps({layout = {preview = false}})<cr>',
  { desc = 'keymaps' }
)
kset('n', '<Leader>sl', '<cmd>lua Snacks.picker.lines()<cr>', { desc = 'buffer lines' })
kset('n', '<Leader>sm', '<cmd>lua Snacks.picker.marks()<cr>', { desc = 'marks' })
kset('n', '<Leader>sn', '<cmd>lua Snacks.picker.notifications()<cr>', { desc = 'notifications' })
kset(
  'n',
  '<Leader>so',
  '<cmd>lua Snacks.picker.recent({filter = { cwd = false }})<cr>',
  { desc = 'oldfiles' }
)
kset('n', '<Leader>sq', '<cmd>lua Snacks.picker.qflist()<cr>', { desc = 'quick fix' })
kset('n', '<Leader>sr', '<cmd>lua Snacks.picker.registers()<cr>', { desc = 'registers' })
kset('n', '<Leader>su', '<cmd>lua Snacks.picker.undo()<cr>', { desc = 'undo history' })
kset('n', '<Leader>sy', '<cmd>lua Snacks.lazygit.open(opts)<cr>', { desc = 'lazygit' })

--  ───── Snacks terminal setup ──────

-- Toggle terminal in a centered floating window
kset({ 'n', 't' }, '<Leader>st', function()
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

kset(
  'n',
  '<Leader>sw',
  '<cmd>lua Snacks.picker.grep_word()<cr>',
  { desc = 'grep selection or word' }
)

kset('n', '<Leader>sz', '<cmd>lua Snacks.zen()<cr>', { desc = 'zen mode' })
kset('n', '<Leader>z', '<cmd>lua Snacks.picker.zoxide()<cr>', { desc = 'zoxide' })

-- Spelling picker
kset('n', 'zz', function()
  require('snacks').picker.spelling({
    -- layout = 'my_spelling',
  })
end, { desc = 'Spelling Suggestions' })

-- Command picker
kset('n', '<Leader>sc', function()
  require('snacks').picker.command_history({
    layout = 'my_keymaps',
    preview = false, -- It doesn't have a preview window in the box, so this is safe
  })
end, { desc = 'cmd history' })

-- Indent toggle
kset('n', '<Leader>si', function()
  if Snacks.indent.enabled then
    Snacks.indent.disable()
  else
    Snacks.indent.enable()
  end
end, { desc = 'Toggle indent Guides' })
