--    ╭────────────────────────────╮
--    │       mini-files.lua       │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local files = require('mini.files')

local file_exclude = require('file_exclude')

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
    trim_left   = '<',
    trim_right  = '>',
  },

  options = {
    -- Don't move deleted entries with dd into Mini.files trash
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
      max_number = 4,
      preview = false,
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

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesWindowOpen',
  callback = function(args)
    vim.api.nvim_win_set_config(args.data.win_id, {
      border = 'double',
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
