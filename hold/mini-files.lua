--    ╭────────────────────────────╮
--    │       mini-files.lua       │
--    ╰────────────────────────────╯

-- Created: 04/30/26
--
-- Kept separate from mini.lua because there is quite a bit here
-- and it can easily be removed if Mini.files is no longer used.
--
-- 07/13/26 from ChatGPT:
--   - Added gc to set Neovim cwd
--   - Mini.files follows external cwd changes
--   - Bookmarks are loaded from bookmarks_linux.lua

-- ─────────── mini.files ───────────

local MiniFiles = require('mini.files')
local cwd_config = require('bookmarks_linux')

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

  MiniFiles.refresh({
    content = {
      filter = show_dotfiles and filter_show or filter_hide,
    },
  })
end

-- ─────────── Preview ───────────

local preview_enabled = true

local function toggle_preview()
  preview_enabled = not preview_enabled

  MiniFiles.refresh({
    windows = {
      preview = preview_enabled,
    },
  })
end

-- ─────────── Setup ───────────

MiniFiles.setup({
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
    close = 'q',
    go_in = 'l',
    go_out = 'h',
    go_out_plus = 'H',
    mark_goto = 'b',
    mark_set = 'm',
    reset = '<BS>',
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

-- ─────────── Open Mini.files ───────────

Kset('n', '<Leader>[', function()
  MiniFiles.open()
end, { desc = 'Mini files' })

-- ─────────── Buffer-local mappings ───────────

local function set_cwd_to_mini()
  local fs_entry = MiniFiles.get_fs_entry()

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
        MiniFiles.set_bookmark(id, expanded, {
          desc = path,
        })
      end
    end

    -- Dynamic bookmark for the current working directory
    MiniFiles.set_bookmark('w', function()
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
    if not MiniFiles.get_explorer_state() then
      return
    end

    local cwd = vim.fs.normalize(vim.fn.getcwd())

    vim.schedule(function()
      if MiniFiles.get_explorer_state() then
        MiniFiles.set_branch({ cwd })
      end
    end)
  end,
  desc = 'Make Mini.files follow Neovim cwd',
})
