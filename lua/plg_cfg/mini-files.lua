--    ╭────────────────────────────╮
--    │       mini-files.lua       │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local files = require('mini.files')

local file_exclude = require('file_exclude')

local group = vim.api.nvim_create_augroup('MyMiniFiles', { clear = true })

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

  -- Hide non-editable file types unless <a-e> has enabled them.
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

local preview_enabled = false

local function toggle_preview()
  local was_enabled = preview_enabled
  preview_enabled = not preview_enabled

  files.refresh({
    windows = {
      preview = preview_enabled,
    },
  })

  if was_enabled then
    local branch = files.get_explorer_state().branch
    table.remove(branch)
    files.set_branch(branch)
  end
end

-- ─────────── Setup ───────────

files.setup({
  content = {
    filter = mini_files_filter,
  },
  mappings = {
    close = '<Esc>',
    go_in = 'l',
    go_in_plus = '<CR>',
    reveal_cwd = '',
    synchronize = 'w',
    reset = '=',
    go_out = '<BS>',
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = false,
  },
})

-- set up size of panels to adjust based on screen size
local function open_minifiles()
  local available = vim.o.columns - 4

  local main_width = math.max(24, math.floor(available / 3))
  local preview_width = math.max(40, available - main_width)

  preview_enabled = false

  files.open(nil, false, {
    windows = {
      max_number = 3,
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
  group = group,
  pattern = 'MiniFilesWindowOpen',
  callback = function(args)
    vim.api.nvim_win_set_config(args.data.win_id, {
      border = 'double',
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

-- bookmarks

local bookmarks = {
  b = { '~/bin', 'Bin' },
  c = { '~/.config', 'Config' },
  d = { '~/.Download', 'Downloads' },
  h = { '~/.config/nvim/hold', 'Hold' },
  H = { '~', 'Home' },
  l = { '~/.local/bin', 'Local bin' },
  L = { '~/.config/nvim/lua', 'Neovim lua' },
  m = { '~/Insync/bertkleinman@outlook.com/OneDrive/My Docs/Moving Forward', 'Moving Forward' },
  n = { '~/.config/nvim', 'Neovim config' },
  o = { '~/Insync/bertkleinman@outlook.com/OneDrive/My Docs', 'OneDrive documents' },
  p = { '~/.config/nvim/lua/plg_cfg', 'Neovim plugins' },
  t = { '~/.Temp', 'Temporary files' },
  v = { '~/Insync/bert.kleinman@gmail.com/Google Drive', 'Google Drive' },
  y = { '~/.config/yazi', 'Yazi config' },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesExplorerOpen',
  callback = function()
    for id, bookmark in pairs(bookmarks) do
      local path = vim.fn.expand(bookmark[1])

      if vim.fn.isdirectory(path) == 1 then
        files.set_bookmark(id, path, {
          desc = bookmark[2],
        })
      else
        vim.notify(
          ('mini.files bookmark %q skipped: directory does not exist\n%s'):format(id, path),
          vim.log.levels.WARN
        )
      end
    end
  end,
})
