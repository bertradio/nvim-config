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

vim.pack.add({ Gh('nvim-mini/mini.nvim') })

local ai = require('mini.ai')
local align = require('mini.align')
local bracketed = require('mini.bracketed')
local clue = require('mini.clue')
local diff = require('mini.diff')
local move = require('mini.move')
local mpairs = require('mini.pairs')
local operators = require('mini.operators')
local surround = require('mini.surround')
local minifiles = require('mini.files')

clue.setup()

-- mini.ai mapping
ai.setup({
  -- disable these so builtin c-space and bs work
  -- for internal visual mode
  mappings = {
    around_next = '',
    inside_next = '',
    around_last = '',
    inside_last = '',
  },
})

align.setup({ mappings = { start = 'ga' } })

bracketed.setup()

--  ───── mini.diff set up for change signs in gutter ─────

diff.setup({
  source = diff.gen_source.save(),
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '-' },
  },
})

vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function(args)
    -- Disable and re-enable refreshes the 'save' source baselineS
    diff.disable(args.buf)
    diff.enable(args.buf)
  end,
})

--  ────── end mini.diff setup ───────


-- stylua: ignore
move.setup({
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

operators.setup()

-- add <> as pair
-- config so ' before a word does not get peired
mpairs.setup({
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

-- stylua: ignore
surround.setup({
  mappings = {
    add            = 'gza',     -- Add surround
    delete         = 'gzd',     -- Delete surround
    find           = 'gzf',     -- Find to the right
    find_left      = 'gzF',     -- Find to the left
    highlight      = 'gzh',     -- Highlight surrounding
    replace        = 'gzr',     -- Replace surround
    update_n_lines = 'gzn',     -- Update n_lines
  },
  n_lines = 50,                 -- search window for surroundings
})

--  ──────── mini.clue setup ─────────

local miniclue = require('mini.clue')

miniclue.setup({

  window = {
    delay = 500,
    config = {
      width = 'auto',
      border = 'rounded',
    },
    scroll_down = '<Down>',
    scroll_up = '<Up>',
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
    -- { mode = 'n', keys = '[' },
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '"' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'x', keys = '`' },
    { mode = 'x', keys = 'g' },
    { mode = 'x', keys = 'z' },
  },

  clues = {

    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>d', desc = '+diff' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>s', desc = '+snacks' },
  },
})

--    ╭────────────────────────────╮
--    │     mini.files configs     │
--    ╰────────────────────────────╯

--
-- 07/13/26 from ChatGPT:
--   - Added gc to set Neovim cwd
--   - Mini.files follows external cwd changes
--   - Bookmarks are loaded from bookmarks_linux.lua

-- local MiniFiles = require('mini.files')
local cwd_config = require('plg_cfg.bookmarks_linux')

local group = vim.api.nvim_create_augroup('MyMiniFiles', { clear = true })

-- ─────────── Filters ───────────

local show_dotfiles = false

local function filter_show(_)
  return true
end

local function filter_hide(fs_entry)
  return not vim.startswith(fs_entry.name, '.')
end

local function toggle_dotfiles()
  show_dotfiles = not show_dotfiles

  minifiles.refresh({
    content = {
      filter = show_dotfiles and filter_show or filter_hide,
    },
  })
end

-- ─────────── Preview ───────────

local preview_enabled = true

local function toggle_preview()
  preview_enabled = not preview_enabled

  minifiles.refresh({
    windows = {
      preview = preview_enabled,
    },
  })
end

-- ─────────── Setup ───────────

minifiles.setup({
  content = {
    -- Hide dotfiles initially
    filter = filter_hide,

    -- What prefix to show to the left of file system entries
    prefix = nil,

    -- In which order to show file system entries
    sort = nil,
  },

  -- Module mappings created only inside the explorer.
  -- Use an empty string to disable a mapping.
  mappings = {
    synchronize = 'w',
    go_in_plus = '<CR>',
    close = '<ESC>',
    go_in = 'l',
    go_out = 'h',
    go_out_plus = 'H', -- go to prior dir
    mark_goto = 'b', -- go to mark set
    mark_set = 'm', -- set mark for this session - not retained
    reset = '<BS>', -- go to dir where entered files
    reveal_cwd = '@',
    show_help = 'g?',
    trim_left = '<',
    trim_right = '>',
  },

  options = {
    -- Move deleted entries into Mini.files trash
    permanent_delete = false,

    -- Use Mini.files when editing a directory
    use_as_default_explorer = true,
  },

  windows = {
    -- Maximum number of windows shown side by side
    max_number = 2,

    -- Show a preview of the entry under the cursor
    preview = preview_enabled,

    -- Width of focused window
    width_focus = 40,

    -- Width of non-focused window
    width_nofocus = 15,

    -- Width of preview window
    width_preview = 55,
  },
})

Kset('n', '<Leader>[', function()
  minifiles.open(vim.fn.getcwd())
end, { desc = 'Mini files cwd' })

-- ─────────── Buffer-local mappings ───────────

local function set_cwd_to_mini()
  local fs_entry = minifiles.get_fs_entry()

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
        minifiles.set_bookmark(id, expanded, {
          desc = path,
        })
      end
    end

    -- Dynamic bookmark for the current working directory
    minifiles.set_bookmark('w', function()
      return vim.fn.getcwd()
    end, {
      desc = 'Current working directory',
    })
  end,
})

-- ─────────── Follow cwd changes ───────────

local syncing_cwd = false

vim.api.nvim_create_autocmd('DirChanged', {
  group = group,
  callback = function()
    if not minifiles.get_explorer_state() then
      return
    end

    local cwd = vim.fs.normalize(vim.fn.getcwd())

    vim.schedule(function()
      if minifiles.get_explorer_state() then
        minifiles.set_branch({ cwd })
      end
    end)
  end,
  desc = 'Make Mini.files follow Neovim cwd',
})
