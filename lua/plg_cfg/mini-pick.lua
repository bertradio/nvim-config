--    ╭────────────────────────────╮
--    │       mini-pick.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local pick = require('mini.pick')
local extra = require('mini.extra')
local exclude = require('file_exclude')

pick.setup()
extra.setup()

-- vim.ui.select = pick.ui_select

pick.config = {
  -- Delays (in ms; should be at least 1)
  delay = {
    -- Delay between forcing asynchronous behavior
    async = 10,

    -- Delay between computation start and visual feedback about it
    busy = 50,
  },

  -- Keys for performing actions. See `:h MiniPick-actions`.
  mappings = {
    caret_left = '<Left>',
    caret_right = '<Right>',

    choose = '<CR>',
    -- choose_in_split = '<C-s>',
    -- choose_in_tabpage = '<C-t>',
    -- choose_in_vsplit = '<C-v>',
    choose_marked = '<M-CR>',

    delete_char = '<BS>',
    delete_char_right = '<Del>',
    delete_left = '<C-u>',
    delete_word = '<C-w>',

    mark = '<C-x>',
    mark_all = '<C-a>',

    move_down = '<C-n>',
    move_start = '<C-g>',
    move_up = '<C-p>',

    -- paste = '<C-r>',
    paste = '<C-v>',

    refine = '<C-Space>',
    refine_marked = '<M-Space>',

    scroll_down = '<PageDown>',
    scroll_left = '<C-h>',
    scroll_right = '<C-l>',
    scroll_up = '<PageUp>',

    stop = '<Esc>',

    toggle_info = '<S-Tab>',
    toggle_preview = '<Tab>',
  },

  -- General options
  options = {
    -- Whether to show content from bottom to top
    content_from_bottom = false,

    -- Whether to cache matches (more speed and memory on repeated prompts)
    use_cache = true,
  },

  -- Source definition. See `:h MiniPick-source`.
  -- stylua: ignore 
  source = {
    choose        = nil,
    choose_marked = nil,
    cwd           = nil,
    items         = nil,
    match         = nil,
    name          = nil,
    preview       = nil,
    show          = nil,
  },

  -- Window related options
  window = {
    -- Float window config (table or callable returning it)
    config = nil,

    -- String to use as caret in prompt
    prompt_caret = '▏',

    -- String to use as prefix in prompt
    prompt_prefix = '> ',
  },
}

local function files_by_name(opts)
  opts = opts or {}

  local cwd = opts.cwd or vim.fn.getcwd()

  local files = vim.fn.systemlist({
    'rg',
    '--files',
    -- '--hidden',
    '--glob',
    '!**/.git/**',
  }, cwd)

  -- Remove files whose extensions are in file_exclude.lua.
  files = vim.tbl_filter(function(path)
    return not exclude.is_excluded(path)
  end, files)

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
      cwd = cwd,
      items = files,
      name = opts.name or 'cwd by name',
    },
  })
end

local zoxide_picker = function()
  local zoxide_output = vim.fn.system('zoxide query -l')
  local zoxide_dirs = vim.split(zoxide_output, '\n', { trimempty = true })
  -- open launcher to choose directory
  -- once a directory is selected, open a second launcher to select a file
  -- from directory using file picker
  pick.start({
    source = {
      items = zoxide_dirs,
      choose = function(dir)
        vim.fn.chdir(dir)
        return pick.builtin.files()
      end,
    },
  })
end

--  ───────── keymaps ──────────

Kset('n', '<Leader><space>', files_by_name, { desc = 'mini.pick files' })

-- Kset('n', '<Leader>]', '<cmd>Pick oldfiles<cr>', { desc = 'mini.pick oldfiles' })
Kset('n', '<Leader>]', function()
  vim.cmd('wshada') -- need to write and re-read shada
  vim.cmd('rshada!') -- to update
  vim.cmd('Pick oldfiles')
end, { desc = 'mini.pick.oldfiles' })

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

Kset('n', '<Leader>pe', function()
  extra.pickers.explorer({
    filter = exclude.mini_explorer_filter,
  })
end, { desc = 'explorer' })

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

Kset('n', '<Leader>pv', function()
  local visits = require('mini.visits')
  local sort_frequent = visits.gen_sort.default({ recency_weight = 1 })
  visits.select_path('', { sort = sort_frequent })
end, { desc = 'visits - recent' })

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

Kset('n', '<Leader>pz', zoxide_picker, { noremap = true, silent = true, desc = 'Zoxide' })

Kset('n', 'zz', function()
  extra.pickers.spellsuggest()
end, { desc = 'spell suggest' })
