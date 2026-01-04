-- files-reddit.lua
--
-- Created: 09/04/25
-- code from Reddit - adds sorting

Myfn.map('n', '<Leader>x', '<cmd>lua MiniFiles.open()<cr>')

vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    -- Check if the module is loaded in Lua's package cache
    local has_minifiles, MiniFiles = pcall(require, 'mini.files')

    -- Only proceed if it exists AND is currently visible
    if has_minifiles and MiniFiles.get_explorer_state() ~= nil then
      MiniFiles.open(vim.fn.getcwd())
    end
  end,
})

local mini_files = require('mini.files')

local CONFIG = {
  width_focus = 50,
  width_nofocus = 15,
  width_nofocus_detailed = 30,
  width_preview = 100,
  sort_limit = 100, -- Max files before disabling details/sorting
  sort_warning_cd = 2000, -- Cooldown for warnings (ms)
  cache_limit = 1000, -- Max No. of dir to be cached
}

local STATE = {
  show_details = true,
  sort_mode = 'name', -- "name" | "date" | "size"
  last_warn_time = 0,
}

local STAT_CACHE = {} -- Map: path -> fs_stat
local CACHED_DIRS = {} -- Set: dir_path -> boolean
local CACHE_DIR_COUNT = 0 -- Counter for cached directories
local LARGE_DIRS = {} -- Set: dir_path -> boolean (Too large for details)

-- Clear cache (used on close, overflow, or synchronize)
local clear_cache = function()
  STAT_CACHE = {}
  CACHED_DIRS = {}
  LARGE_DIRS = {}
  CACHE_DIR_COUNT = 0
end

local ensure_stats = function(fs_entries)
  if #fs_entries == 0 then
    return
  end

  local dir_path = vim.fs.dirname(fs_entries[1].path)

  if not CACHED_DIRS[dir_path] then
    if CACHE_DIR_COUNT >= CONFIG.cache_limit then
      clear_cache()
    end
    CACHED_DIRS[dir_path] = true
    CACHE_DIR_COUNT = CACHE_DIR_COUNT + 1
  end

  for _, entry in ipairs(fs_entries) do
    if not STAT_CACHE[entry.path] then
      STAT_CACHE[entry.path] = vim.uv.fs_stat(entry.path)
    end
  end
end

local format_size = function(size)
  if not size then
    return ''
  end
  if size < 1024 then
    return string.format('%3dB', size)
  elseif size < 1048576 then
    return string.format('%3.0fK', size / 1024)
  else
    return string.format('%3.0fM', size / 1048576)
  end
end

local format_time = function(time)
  if not time then
    return ''
  end
  return os.date('%y-%m-%d %H:%M', time.sec)
end

local my_pre_prefix = function(fs_stat)
  if not fs_stat then
    return ''
  end
  local parts = {}
  local mtime = format_time(fs_stat.mtime)
  if mtime ~= '' then
    table.insert(parts, mtime)
  end

  if fs_stat.type == 'file' then
    local size = format_size(fs_stat.size)
    if size ~= '' then
      table.insert(parts, size)
    end
  end

  if #parts == 0 then
    return ''
  end
  return table.concat(parts, ' ')
end

local my_prefix = function(fs_entry)
  if not STATE.show_details then
    return mini_files.default_prefix(fs_entry)
  end

  local fs_stat = STAT_CACHE[fs_entry.path]
  -- Fallback: In case fs_stat is missing (due to cache clearance), fetch now
  local parent_dir = vim.fs.dirname(fs_entry.path)
  if not fs_stat and not LARGE_DIRS[parent_dir] then
    fs_stat = vim.uv.fs_stat(fs_entry.path)
    STAT_CACHE[fs_entry.path] = fs_stat
  end

  local prefix, hl = mini_files.default_prefix(fs_entry)

  local pre_prefix = '...'
  if not LARGE_DIRS[parent_dir] then
    pre_prefix = my_pre_prefix(fs_stat)
  end

  if pre_prefix == '' then
    return prefix, hl
  end
  return pre_prefix .. ' ' .. prefix, hl
end

local sorter = function(fs_entries, fs_accessor)
  table.sort(fs_entries, function(a, b)
    -- 1. Directories always come first and sorted by name
    if a.fs_type ~= b.fs_type then
      return a.fs_type == 'directory'
    end
    if a.fs_type == 'directory' then
      return a.name:lower() < b.name:lower()
    end
    -- 2. Files are sorted using the fs_accessor
    local stat_a = STAT_CACHE[a.path]
    local stat_b = STAT_CACHE[b.path]

    local val_a = stat_a and fs_accessor(stat_a) or 0
    local val_b = stat_b and fs_accessor(stat_b) or 0
    return val_a > val_b
  end)
  return fs_entries
end

local custom_sort = function(fs_entries)
  if #fs_entries == 0 then
    return fs_entries
  end

  local dir_path = vim.fs.dirname(fs_entries[1].path)

  -- 1. Check if Active Directory
  local explorer = mini_files.get_explorer_state()
  local is_active = false
  if explorer then
    local focused_dir = explorer.branch[explorer.depth_focus]
    if dir_path == focused_dir then
      is_active = true
    end
  end

  -- 2. Check if the dir too big
  if #fs_entries > CONFIG.sort_limit then
    -- if file_count > CONFIG.sort_limit then
    LARGE_DIRS[dir_path] = true

    if is_active and STATE.sort_mode ~= 'name' then
      local now = vim.uv.now()
      if (now - STATE.last_warn_time) > CONFIG.sort_warning_cd then
        vim.notify(
          'Directory too large ('
            .. #fs_entries
            .. ' > '
            .. CONFIG.sort_limit
            .. '). Sorting aborted.',
          vim.log.levels.WARN
        )
        STATE.last_warn_time = now
      end
    end

    return mini_files.default_sort(fs_entries)
  else
    LARGE_DIRS[dir_path] = nil
  end

  local mode_to_use = is_active and STATE.sort_mode or 'name'

  if STATE.show_details or mode_to_use ~= 'name' then
    ensure_stats(fs_entries)
  end

  -- 3. perform sorting
  if mode_to_use == 'size' then
    return sorter(fs_entries, function(s)
      return s.size
    end)
  elseif mode_to_use == 'date' then
    return sorter(fs_entries, function(s)
      return s.mtime.sec
    end)
  else
    return mini_files.default_sort(fs_entries)
  end
end

local toggle_details = function()
  STATE.show_details = not STATE.show_details
  local new_width = STATE.show_details and CONFIG.width_nofocus_detailed or CONFIG.width_nofocus
  mini_files.refresh({
    windows = { width_nofocus = new_width },
    content = { prefix = my_prefix },
  })
end

local set_sort = function(mode)
  if STATE.sort_mode == mode then
    return
  end
  STATE.sort_mode = mode

  local msg = 'Sort: Name (A-Z)'
  if mode == 'size' then
    msg = 'Sort: Size (Descending)'
  end
  if mode == 'date' then
    msg = 'Sort: Date (Newest)'
  end

  vim.notify(msg, vim.log.levels.INFO)
  mini_files.refresh({ content = { sort = custom_sort } })
end

local safe_synchronize = function()
  mini_files.synchronize()
  clear_cache()
  -- vim.notify("Synchronized & Cache Cleared", vim.log.levels.INFO)
end

mini_files.setup({
  mappings = {
    go_in_plus = '<CR>',
    trim_left = '>',
    trim_right = '<',
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = false,
  },
  windows = {
    max_number = math.huge,
    preview = true,
    width_focus = CONFIG.width_focus,
    width_nofocus = CONFIG.width_nofocus_detailed,
    width_preview = CONFIG.width_preview,
  },
  content = { prefix = my_prefix, sort = custom_sort },
})

-- Navigation Wrappers
local go_in_reset = function()
  STATE.sort_mode = 'name'
  mini_files.go_in()
end

local go_out_reset = function()
  STATE.sort_mode = 'name'
  mini_files.go_out()
end

local go_in_plus_reset = function()
  STATE.sort_mode = 'name'
  mini_files.go_in({ close_on_file = true })
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesWindowClose',
  callback = function()
    clear_cache()
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  group = vim.api.nvim_create_augroup('mini-file-buffer', { clear = true }),
  callback = function(args)
    local b = args.data.buf_id
    local map = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = b, desc = desc })
    end

    map('l', go_in_reset, 'Go in (Reset Sort)')
    map('h', go_out_reset, 'Go out (Reset Sort)')
    map('<CR>', go_in_plus_reset, 'Go in plus (Reset Sort)')

    map(',,', toggle_details, 'Toggle file details')
    map(',s', function()
      set_sort('size')
    end, 'Sort by Size')
    map(',m', function()
      set_sort('date')
    end, 'Sort by Modified')
    map(',a', function()
      set_sort('name')
    end, 'Sort by Name')

    map('=', safe_synchronize, 'Synchronize & Clear Cache')
    map('<esc>', mini_files.close, 'Close')
  end,
})
