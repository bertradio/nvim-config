-- mini-files.lua

-- Created: 04/30/26

--  ─────────── mini.files ───────────

vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('MiniFilesSync', { clear = true }),
  callback = function()
    -- Safely check if the module is even available in the package path
    local has_mf, mf = pcall(require, 'mini.files')
    -- Only proceed if the module is loaded AND the explorer is currently visible
    if has_mf and mf.get_explorer_state() ~= nil then
      mf.open(vim.fn.getcwd())
    end
  end,
})

Kset('n', '<Leader>[', function()
  require('mini.files').open()
end, { desc = 'mini files' })

require('mini.files').setup({

  content = {
    -- Predicate for which file system entries to show
    filter = nil,
    -- What prefix to show to the left of file system entry
    prefix = nil,
    -- In which order to show file system entries
    sort = nil,
  },

  -- Module mappings created only inside explorer.
  -- Use `''` (empty string) to not create one.
  mappings = {
    synchronize = 'w',
    go_in_plus = '<CR>',
    close = 'q',
    go_in = 'l',
    go_out = 'h',
    go_out_plus = 'H',
    mark_goto = "'",
    mark_set = 'm',
    reset = '<BS>',
    reveal_cwd = '@',
    show_help = 'g?',
    trim_left = '<',
    trim_right = '>',
  },

  -- General options
  options = {
    -- Whether to delete permanently or move into module-specific trash
    permanent_delete = false,
    -- Whether to use for editing directories
    use_as_default_explorer = false,
  },

  -- Customization of explorer windows
  windows = {
    -- Maximum number of windows to show side by side
    -- max_number = math.huge,
    max_number = 1,
    -- Whether to show preview of file/directory under cursor
    preview = false,
    -- Width of focused window
    width_focus = 60,
    -- Width of non-focused window
    width_nofocus = 15,
    -- Width of preview window
    width_preview = 35,
  },
})

local show_dotfiles = false

local filter_show = function(fs_entry)
  return true
end

local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, '.')
end

local gio_open = function()
  local fs_entry = require('mini.files').get_fs_entry()
  vim.notify(vim.inspect(fs_entry))
  vim.fn.system(string.format("gio open '%s'", fs_entry.path))
end

local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  require('mini.files').refresh({ content = { filter = new_filter } })
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Tweak left-hand side of mapping to your liking
    Kset('n', 'g.', toggle_dotfiles, { buffer = buf_id })
    Kset('n', '<Leade>[', require('mini.files').close, { buffer = buf_id })
    -- Kset('n', 'o', gio_open, { buffer = buf_id })
  end,
})
