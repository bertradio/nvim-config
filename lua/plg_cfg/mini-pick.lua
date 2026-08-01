--    ╭────────────────────────────╮
--    │       mini-pick.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local pick = require('mini.pick')
local extra = require('mini.extra')

pick.setup()
extra.setup()

local function files_by_name(opts)
  opts = opts or {}

  local cwd = opts.cwd or vim.fn.getcwd()
  local files = vim.fn.systemlist({
    'rg',
    '--files',
    '--hidden',
    '--glob',
    '!**/.git/**',
  }, cwd)

  table.sort(files, function(a, b)
    local name_a = vim.fs.basename(a):lower()
    local name_b = vim.fs.basename(b):lower()

    if name_a == name_b then
      return a:lower() < b:lower()
    end

    return name_a < name_b
  end)

  pick.start({
    source = {
      name = opts.name or 'Files by name',
      cwd = cwd,
      items = files,
    },
  })
end

Kset('n', '<Leader><space>', files_by_name, { desc = 'mini.pick files' })
Kset('n', '<Leader>]', '<cmd>Pick oldfiles<cr>', { desc = 'mini.pick oldfiles' })

Kset('n', '<Leader>p.', function()
  pick.builtin.resume()
end, { desc = 'resume last picker' })

Kset('n', '<Leader>pb', function()
  pick.builtin.buffers()
end, { desc = 'buffers' })

Kset('n', '<Leader>pc', function()
  extra.pickers.history({ scope = ':' })
end, { desc = 'command history' })

Kset('n', '<Leader>pd', function()
  extra.pickers.diagnostic({ scope = 'current' })
end, { desc = 'diagnostics' })

Kset('n', '<Leader>pg', function()
  pick.builtin.grep()
end, { desc = 'grep' })

Kset('n', '<Leader>pG', function()
  pick.builtin.grep_live()
end, { desc = 'live grep' })

Kset('n', '<Leader>ph', function()
  pick.builtin.help()
end, { desc = 'helptags' })

Kset('n', '<Leader>pH', function()
  extra.pickers.hl_groups()
end, { desc = 'highlights' })

Kset('n', '<Leader>pi', function()
  extra.pickers.lsp({ scope = 'implementation' })
end, { desc = 'lsp implementations' })

Kset('n', '<Leader>pj', function()
  extra.pickers.list({ scope = 'jump' })
end, { desc = 'jumps' })

Kset('n', '<Leader>pk', function()
  extra.pickers.keymaps()
end, { desc = 'keymaps' })

Kset('n', '<Leader>pl', function()
  extra.pickers.buf_lines({ scope = 'current' })
end, { desc = 'lines' })

Kset('n', '<Leader>pm', function()
  extra.pickers.marks()
end, { desc = 'marks' })

Kset('n', '<Leader>po', function()
  extra.pickers.lsp({ scope = 'document_symbol' })
end, { desc = 'document symbols' })

Kset('n', '<Leader>pO', function()
  extra.pickers.lsp({ scope = 'workspace_symbol' })
end, { desc = 'workspace symbols' })

Kset('n', '<Leader>pq', function()
  extra.pickers.list({ scope = 'quickfix' })
end, { desc = 'quickfix' })

Kset('n', '<Leader>pr', function()
  extra.pickers.registers()
end, { desc = 'registers' })

Kset('n', '<Leader>pR', function()
  extra.pickers.lsp({ scope = 'references' })
end, { desc = 'lsp references' })

Kset('n', '<Leader>ps', function()
  extra.pickers.history({ scope = '/' })
end, { desc = 'search history' })

Kset('n', '<Leader>pu', function()
  extra.pickers.commands()
end, { desc = 'commands' })

Kset('n', '<Leader>pw', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cword>'),
  })
end, { desc = 'grep word under cursor' })

Kset('n', '<Leader>pW', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cWORD>'),
  })
end, { desc = 'grep WORD under cursor' })

Kset('n', '<Leader>px', function()
  extra.pickers.list({ scope = 'change' })
end, { desc = 'changes' })

Kset('n', 'zz', function()
  extra.pickers.spellsuggest()
end, { desc = 'spell suggest' })

Kset('n', '<Leader>pn', function()
  pick.builtin.files(nil, {
    source = {
      cwd = vim.fn.stdpath('config'),
      name = 'Neovim',
    },
  })
end, { desc = 'Neovim config' })
