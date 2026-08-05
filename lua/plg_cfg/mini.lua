--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from aucmds.lua
-- 04/29/26 - add autocmd to delay most require until typing
-- 05/03/26 - configured menu to replace Snacks - code from Gemini - consolidated and tuned shortcuts
-- 05/04/26 - fixed issue with recent not updating by adding rshada! to shortcut
-- 05/08/26 - cleaned up and optimized starter
-- 05/20/26 - added local requires
-- 06/01/26 - replaced starter with Snacks.dashboard
-- 07/15/26 - added mini.clues and mini.files configs
-- 07/26/26 - added mini.ai - code as per ChatGPT
-- 07/31/26 - added indentscope

<<<<<<< Updated upstream
vim.pack.add({
  Gh('nvim-mini/mini.nvim'),
  -- for mini.ai to use treesitter
  {
    src = Gh('nvim-treesitter/nvim-treesitter-textobjects'),
    version = 'main',
  },
})
=======
--   Gh('nvim-mini/mini.nvim'),
-- })
>>>>>>> Stashed changes

local ai = require('mini.ai')
local align = require('mini.align')
local animate = require('mini.animate')
local bracketed = require('mini.bracketed')
local bufremove = require('mini.bufremove')
<<<<<<< Updated upstream
local clue = require('mini.clue')
local diff = require('mini.diff')
local file_exclude = require('file_exclude')
local files = require('mini.files')
local indentscope = require('mini.indentscope')
local jump2d = require('mini.jump2d')
local mjump = require('mini.jump')
local move = require('mini.move')
local mpairs = require('mini.pairs')
local notify = require('mini.notify')
local surround = require('mini.surround')
local pick = require('mini.pick')
local extra = require('mini.extra')

-- ───── mini.ai text objects ─────

local ts_textobject = ai.gen_spec.treesitter

ai.setup({
  n_lines = 500,

  custom_textobjects = {
    -- Function
    F = ts_textobject({
      a = '@function.outer',
      i = '@function.inner',
    }),

    -- Function call
    c = ts_textobject({
      a = '@call.outer',
      i = '@call.inner',
    }),

    -- Argument or parameter
    a = ts_textobject({
      a = '@parameter.outer',
      i = '@parameter.inner',
    }),

    -- Conditional or loop
    o = ts_textobject({
      a = {
        '@conditional.outer',
        '@loop.outer',
      },
      i = {
        '@conditional.inner',
        '@loop.inner',
      },
    }),

    -- Assignment
    A = ts_textobject({
      a = '@assignment.outer',
      i = {
        '@assignment.lhs',
        '@assignment.rhs',
      },
    }),

    -- Comment
    C = ts_textobject({
      a = '@comment.outer',
      i = '@comment.inner',
    }),
  },

  mappings = {
    around = 'a',
    inside = 'i',

    around_next = 'an',
    inside_next = 'in',

    around_last = 'al',
    inside_last = 'il',

    goto_left = 'g[',
    goto_right = 'g]',
  },

  search_method = 'cover_or_next',
  silent = false,
})
=======
local minput = require('mini.input')
>>>>>>> Stashed changes

--  ──────────────────────────────────────────────────────

align.setup({ mappings = { start = 'ga' } })

animate.setup()

bracketed.setup()

--  ──────────────────────────────────────────────────────

bufremove.setup()

<<<<<<< Updated upstream
--  ──────── mini.clue setup ─────────

clue.setup({

  -- stylua: ignore 
  window = {
    delay  = 500,
    config = {
      width  = 'auto',
      border = 'rounded',
    },
    scroll_down = '<Down>',
    scroll_up   = '<Up>',
  },

  triggers = {
    { mode = 'c', keys = '<C-r>' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'i', keys = '<C-x>' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '"' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = '<Leader>' },
    { mode = 'n', keys = '`' },
    { mode = 'n', keys = 'g' },
    { mode = 'n', keys = 'z' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '"' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'x', keys = '`' },
    { mode = 'x', keys = 'g' },
    { mode = 'x', keys = 'z' },
  },

  clues = {

    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>f', desc = '+fzf' },
    { mode = 'n', keys = '<Leader>m', desc = '+pretty' },
    { mode = 'n', keys = '<Leader>p', desc = '+mini.pick' },
  },
})

--  ──────────────────────── end mini.ai setup ────────────────────────

--  ───── ───── mini.diff set up for change signs in gutter ───── ─────

diff.setup({
  source = diff.gen_source.save(),
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '-' },
  },
})

vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function(args)
    -- Disable and re-enable refreshes the 'save' source baselines
    diff.disable(args.buf)
    diff.enable(args.buf)
  end,
})

--  ────── end mini.diff setup ───────

--  ─────── identscope config ────────

indentscope.setup({})

-- set symbol color
vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', {
  -- fg = '#f38ba6', -- red
  fg = '#ffffff', -- white

  nocombine = true,
})

--  ─────────────────────────────────── mini.jump ───────────────────────────────────
-- code from ChatGPT
-- Improved f, F, t, and T motions.

mjump.setup({
  mappings = {
    forward = 'f',
    backward = 'F',
    forward_till = 't',
    backward_till = 'T',
    repeat_jump = ';',
  },

  delay = {
    -- Wait before highlighting additional matching characters.
    highlight = 0,

    -- Effectively disables automatic timeout.
    idle_stop = 10000000,
  },

  silent = true,
})

--  ────────── mini.jump2d ───────────

-- code from ChatGPT
-- Press s and choose a label at the beginning of a word.
-- S to select beginning of words
-- gl for beginning of lines
-----------------------------------------------------------------------

jump2d.setup({
  -- Disable the module's default <CR> mapping.
  mappings = {
    start_jumping = '',
  },

  -- Most convenient labels appear first.
  labels = 'asdfghjklqwertyuiopzxcvbnm',

  view = {
    dim = true,

    -- Show only the next label needed.
    n_steps_ahead = 0,
  },

  allowed_lines = {
    blank = false,
    cursor_before = true,
    cursor_at = true,
    cursor_after = true,
    fold = true,
  },

  allowed_windows = {
    current = true,
    not_current = true,
  },

  silent = true,
})

-- Flash-like jump to the beginning of a word.
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  jump2d.start(jump2d.builtin_opts.word_start)
end, {
  desc = 'Jump to word start',
})

-- Optional: jump to any occurrence of a typed character.
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  jump2d.start(jump2d.builtin_opts.single_character)
end, {
  desc = 'Jump to character',
})

-- Optional: jump to the beginning of a visible line.
vim.keymap.set({ 'n', 'x', 'o' }, 'gl', function()
  jump2d.start(jump2d.builtin_opts.line_start)
end, {
  desc = 'Jump to line start',
})

--  ───── Highlights for Catppuccin Mocha ─────

local function set_jump_highlights()
  -- mini.jump matching characters
  vim.api.nvim_set_hl(0, 'MiniJump', {
    fg = '#f9e2af',
    bold = true,
    underline = true,
  })

  -- mini.jump2d labels
  vim.api.nvim_set_hl(0, 'MiniJump2dSpot', {
    fg = '#1e1e2e',
    bg = '#f9e2af',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dSpotUnique', {
    fg = '#1e1e2e',
    bg = '#a6e3a1',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dSpotAhead', {
    fg = '#1e1e2e',
    bg = '#89b4fa',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dDim', {
    fg = '#6c7086',
  })
end

set_jump_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_jump_highlights,
})

--  ──────── end junp2d setup ────────

move.setup({
  -- stylua: ignore
  mappings = {
    down       = '<C-down>',
    left       = '<C-left>',
    line_down  = '<C-down>',
    line_left  = '<C-left>',
    line_right = '<C-right>',
    line_up    = '<C-up>',
    right      = '<C-right>',
    up         = '<C-up>',
  },
})

mpairs.setup({
  -- add <> as pair
  -- config so ' before a word does not get peired
  mappings = {
    -- pair < >
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '^[^\\]' },
    ['>'] = { action = 'close', pair = '<>', neigh_pattern = '^[^\\]' },
    -- do not double quote before words
    ["'"] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = "''",
      register = { cr = false },
    },
    ['"'] = {
      action = 'closeopen',
      neigh_pattern = '[^%w][^%w]',
      pair = '""',
      register = { cr = false },
    },
  },
})

--  ───────── notify setup ──────────

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

--  ──────────────────────────────────────────────────────

surround.setup({
  -- stylua: ignore
  mappings = {
    add            = 'gza',     -- Add surround
    delete         = 'gzd',     -- Delete surround
    find           = 'gzf',     -- Find to the right
    find_left      = 'gzF',     -- Find to the left
    highlight      = 'gzh',     -- Highlight surrounding
    replace        = 'gzr',     -- Replace surround
    update_n_lines = 'gzn',     -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})

--  ──────────────────────────────────────────────────────

--    ╭────────────────────────────╮
--    │     mini.files configs     │
--    ╰────────────────────────────╯

local cwd_config = require('plg_cfg.bookmarks_' .. (Myfn.is_windows() and 'win' or 'linux'))

local group = vim.api.nvim_create_augroup('MyMiniFiles', { clear = true })

local function trash_entry()
  local entry = files.get_fs_entry()

  if not entry or not entry.path then
    vim.notify('No entry under cursor', vim.log.levels.WARN)
    return
  end

  local choice = vim.fn.confirm('Move to system Trash?\n\n' .. entry.path .. '\n', '&Yes\n&No', 2)

  if choice ~= 1 then
    return
  end

  local result = vim.system({ 'gio', 'trash', entry.path }, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify('gio trash failed:\n' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end

  files.synchronize()

  vim.notify(('Moved "%s" to Trash'):format(vim.fs.basename(entry.path)))
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    Kset('n', 'T', trash_entry, {
      buffer = args.data.buf_id,
      desc = 'Move to system Trash',
    })
  end,
})

-- ─────────── Filters ───────────

local show_dotfiles = false
local show_excluded = false

local function mini_files_filter(fs_entry)
  local name = fs_entry.name

  -- Hide dotfiles unless g. has enabled them.
  if not show_dotfiles and vim.startswith(name, '.') then
    return false
  end

  -- Always allow ordinary directories.
  -- Dot-directories were already handled above.
  if fs_entry.fs_type == 'directory' then
    return true
  end

  -- Hide non-editable file types unless gE has enabled them.
  if not show_excluded and file_exclude.is_excluded(name) then
    return false
  end

  return true
end

local function refresh_filter()
  files.refresh({
    content = {
      filter = mini_files_filter,
    },
  })
end

local function toggle_dotfiles()
  show_dotfiles = not show_dotfiles
  refresh_filter()

  vim.notify(show_dotfiles and 'Dotfiles shown' or 'Dotfiles hidden')
end

local function toggle_excluded()
  show_excluded = not show_excluded
  refresh_filter()

  vim.notify(show_excluded and 'Excluded files shown' or 'Excluded files hidden')
end

-- ─────────── Preview ───────────

local preview_enabled = true

local function toggle_preview()
  preview_enabled = not preview_enabled

  files.refresh({
    windows = {
      preview = preview_enabled,
    },
  })
end

-- ─────────── Setup ───────────

files.setup({
  content = {

    filter = mini_files_filter,

    -- What prefix to show to the left of file system entries
    prefix = nil,

    -- In which order to show file system entries
    sort = nil,
  },

  -- Module mappings created only inside the explorer.
  -- Use an empty string to disable a mapping.
-- stylua: ignore 
  mappings = {
    synchronize = 'w',
    go_in_plus  = '<CR>',
    close       = '<ESC>',
    go_in       = 'l',
    go_out      = 'h',
    go_out_plus = 'H', -- go to prior dir
    mark_goto   = "'", -- go to mark set
    mark_set    = 'm', -- set mark for this session - not retained
    reset       = '<BS>', -- go to dir where entered files
    reveal_cwd  = '',
    show_help   = 'g?',
    trim_left   = '',
    trim_right  = '',
  },

  options = {
    -- Dom't move deleted entries with dd into Mini.files trash
    -- Instead permanently delete - use <Leader>T to delete to system trash
    permanent_delete = true,

    -- Use Mini.files when editing a directory
    use_as_default_explorer = true,
  },
})

-- set up size of panels to adjyst based on screen size
local function open_minifiles()
  local available = vim.o.columns - 4

  local main_width = math.max(24, math.floor(available / 3))
  local preview_width = math.max(40, available - main_width)

  files.open(nil, false, {
    windows = {
      max_number = 2,
      preview = true,
      width_focus = main_width,
      width_preview = preview_width,
    },
  })
end

Kset('n', '<Leader>[', open_minifiles, { desc = 'mini.files' })

-- ─────────── Buffer-local mappings ───────────

local function set_cwd_to_mini()
  local fs_entry = files.get_fs_entry()

  if not fs_entry then
    return
  end

  local path = fs_entry.path

  -- When the cursor is on a file, use its parent directory
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fs.dirname(path)
  end

  path = vim.fs.normalize(path)

  vim.cmd.cd(vim.fn.fnameescape(path))
end

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesBufferCreate',

  callback = function(args)
    local buf_id = args.data.buf_id

    Kset('n', 'g.', toggle_dotfiles, {
      buffer = buf_id,
      desc = 'Toggle dotfiles',
    })

    -- Kset('n', 'gE', toggle_excluded, {
    Kset('n', '<a-e>', toggle_excluded, {
      buffer = buf_id,
      desc = 'Toggle excluded files',
    })

    Kset('n', '<C-p>', toggle_preview, {
      buffer = buf_id,
      desc = 'Toggle preview',
    })

    Kset('n', 'gc', set_cwd_to_mini, {
      buffer = buf_id,
      desc = 'Set cwd to current Mini.files directory',
    })
  end,
})

-- ─────────── Bookmarks ───────────

local function expand_path(path)
  path = path:gsub('^~', vim.env.HOME)
  path = path:gsub('%$HOME', vim.env.HOME)

  return vim.fs.normalize(vim.fn.expand(path))
end

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesExplorerOpen',

  callback = function()
    -- Load the same bookmarks used by bookmarks_linux.lua
    for id, path in pairs(cwd_config) do
      local expanded = expand_path(path)

      if vim.fn.isdirectory(expanded) == 1 then
        files.set_bookmark(id, expanded, {
          desc = path,
        })
      end
    end

    -- Dynamic bookmark for the current working directory
    files.set_bookmark('w', function()
      return vim.fn.getcwd()
    end, {
      desc = 'Current working directory',
    })
  end,
})

-- ─────────── Follow cwd changes ───────────

vim.api.nvim_create_autocmd('DirChanged', {
  group = group,
  callback = function()
    if not files.get_explorer_state() then
      return
    end

    local cwd = vim.fs.normalize(vim.fn.getcwd())

    vim.schedule(function()
      if files.get_explorer_state() then
        files.set_branch({ cwd })
      end
    end)
  end,
  desc = 'Make Mini.files follow Neovim cwd',
})

--  ─────────── mini.pick setup ───────────

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
=======
minput.setup()
>>>>>>> Stashed changes
