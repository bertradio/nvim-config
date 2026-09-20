--    ╭────────────────────────────╮
--    │       mini-pick.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua
-- 09/15/26 - Replaced <leader>fp code to simplify - from Deepseek
-- 09/19/26 - Moved picks window to centered on screen
--            Added BS in explorer to move to prior dir
--            Centered picker box and dimmed screen

local pick = require('mini.pick')
local extra = require('mini.extra')
local exclude = require('file_exclude')
local minput = require('mini.input')
local visits = require('mini.visits')

visits.setup()

pick.setup({
  mappings = {
    choose_in_split = '<M-s>',
    choose_in_tabpage = '',
    choose_in_vsplit = '<M-v>',
    paste = '<C-v>',
    scroll_down = '<PageDown>',
    scroll_up = '<PageUp>',
  },
  options = {
    use_cache = true,
  },
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)

      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
})

--  ───── functions to dim background when pick displays ─────

local backdrop = {}
local backdrop_group = vim.api.nvim_create_augroup('MiniPickBackdrop', { clear = true })

local function close_backdrop()
  if vim.api.nvim_win_is_valid(backdrop.win or -1) then
    vim.api.nvim_win_close(backdrop.win, true)
  end
  if vim.api.nvim_buf_is_valid(backdrop.buf or -1) then
    vim.api.nvim_buf_delete(backdrop.buf, { force = true })
  end
  backdrop = {}
end

local function resize_backdrop()
  if not vim.api.nvim_win_is_valid(backdrop.win or -1) then
    return
  end

  vim.api.nvim_win_set_config(backdrop.win, {
    relative = 'editor',
    row = 0,
    col = 0,
    width = vim.o.columns,
    height = vim.o.lines - vim.o.cmdheight,
  })
end

local function open_backdrop()
  close_backdrop()
  vim.api.nvim_set_hl(0, 'MiniPickBackdrop', { bg = '#000000' })

  backdrop.buf = vim.api.nvim_create_buf(false, true)
  backdrop.win = vim.api.nvim_open_win(backdrop.buf, false, {
    relative = 'editor',
    row = 0,
    col = 0,
    width = vim.o.columns,
    height = vim.o.lines - vim.o.cmdheight,
    style = 'minimal',
    focusable = false,
    noautocmd = true,
    zindex = 250,
  })

  vim.wo[backdrop.win].winblend = 70 -- set dim as percent of black (0%)
  vim.wo[backdrop.win].winhighlight = 'Normal:MiniPickBackdrop'
  vim.cmd('redraw')
end

vim.api.nvim_create_autocmd('User', {
  group = backdrop_group,
  pattern = 'MiniPickStart',
  callback = open_backdrop,
})

vim.api.nvim_create_autocmd('User', {
  group = backdrop_group,
  pattern = 'MiniPickStop',
  callback = close_backdrop,
})

vim.api.nvim_create_autocmd('VimResized', {
  group = backdrop_group,
  callback = resize_backdrop,
})

--  ───── end functions for background dim ─────

extra.setup()

local function zoxide_picker()
  if vim.fn.executable('zoxide') == 0 then
    vim.notify('zoxide is not installed or not in PATH', vim.log.levels.ERROR)
    return
  end

  local zoxide_dirs = vim.fn.systemlist({ 'zoxide', 'query', '--list' })
  if vim.v.shell_error ~= 0 then
    vim.notify('Could not read zoxide directories', vim.log.levels.ERROR)
    return
  end

  pick.start({
    source = {
      items = zoxide_dirs,
      name = 'Zoxide directories',
      choose = function(dir)
        return pick.builtin.files(nil, {
          source = { cwd = dir },
        })
      end,
    },
  })
end

--  ───── put grep input in middle of screen and dim background ─────

local function grep_picker()
  open_backdrop()

  local pattern = minput.get({
    prompt = '(mini.pick) Grep pattern',
    scope = 'editor',
    completion = 'file',
    handlers = {
      view = minput.gen_view.floatwin({ style = 'MM' }),
    },
  })

  if pattern == nil then
    close_backdrop()
    return
  end

  pick.builtin.grep({ pattern = pattern })
end

--  ───────── keymaps ──────────

-- Kset('n', '<Leader>pf', function()
Kset('n', '<Leader><space>', function()
  local files = vim.fn.systemlist({ 'rg', '--files', '--glob', '!**/.git/**' })
  files = vim.tbl_filter(function(path)
    return not exclude.is_excluded(path)
  end, files)

  -- sort list by filename
  table.sort(files, function(a, b)
    local name_a = vim.fs.basename(a):lower()
    local name_b = vim.fs.basename(b):lower()
    if name_a == name_b then
      return a:lower() < b:lower()
    end
    return name_a < name_b
  end)

  pick.start({
    source = { name = 'cwd by name', items = files },
  })
end, { desc = 'files' })

Kset('n', '<Leader>pr', function()
  vim.cmd.wshada()
  extra.pickers.oldfiles()
end, { desc = 'oldfiles' })

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
  }, {
    mappings = {
      delete_char = '',
      go_to_parent = {
        char = '<BS>',
        func = function()
          local picker_opts = pick.get_picker_opts()
          local cwd = picker_opts.source.cwd
          local parent = vim.fs.dirname(cwd)

          if not parent or parent == cwd then
            return
          end

          picker_opts.source.choose({
            fs_type = 'directory',
            path = parent,
            text = vim.fs.basename(parent),
          })
        end,
      },
    },
  })
end, { desc = 'explorer' })

Kset('n', '<Leader>pg', grep_picker, { desc = 'grep' })

Kset('n', '<Leader>pG', function()
  pick.builtin.grep_live()
end, { desc = 'Live grep' })

Kset('n', '<Leader>pH', function()
  extra.pickers.hl_groups()
end, { desc = 'Highlights' })

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

Kset('n', '<Leader>pq', function()
  extra.pickers.list({ scope = 'quickfix' })
end, { desc = 'quickfix' })

Kset('n', '<Leader>pR', function()
  extra.pickers.registers()
end, { desc = 'Registers' })

Kset('n', '<Leader>ps', function()
  extra.pickers.history({ scope = '/' })
end, { desc = 'search history' })

Kset('n', '<Leader>pw', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cword>'),
    method = 'fixed',
  })
end, { desc = 'grep word under cursor' })

Kset('n', '<Leader>pW', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cWORD>'),
    method = 'fixed',
  })
end, { desc = 'grep WORD under cursor' })

Kset('n', '<Leader>px', function()
  extra.pickers.list({ scope = 'change' })
end, { desc = 'changes' })

Kset('n', '<Leader>pz', zoxide_picker, { noremap = true, silent = true, desc = 'Zoxide' })

Kset('n', '<Leader>pv', function()
  local sort_recent = visits.gen_sort.default({ recency_weight = 1 })

  local paths = visits.list_paths('', {
    sort = sort_recent,
  })

  paths = vim.tbl_filter(function(path)
    local stat = vim.uv.fs_stat(path)
    return stat and stat.type == 'file'
  end, paths)

  local items = vim.tbl_map(function(path)
    return {
      path = path,
      text = path,
    }
  end, paths)

  pick.start({
    source = {
      name = 'Visits - recent',
      items = items,

      show = function(buf_id, items_to_show, query)
        local win_id = vim.fn.bufwinid(buf_id)
        local win_width = win_id ~= -1 and vim.api.nvim_win_get_width(win_id) or 100

        local date_width = 16 -- YYYY-MM-DD HH:MM
        local separator = ' │ '
        local path_width = math.max(20, win_width - date_width - #separator + 1)

        local display_items = vim.tbl_map(function(item)
          local stat = vim.uv.fs_stat(item.path)

          local modified = ''
          if stat and stat.mtime then
            modified = os.date('%Y-%m-%d %H:%M', stat.mtime.sec)
          end

          local path = item.path
          local relative = vim.fs.relpath(vim.fn.getcwd(), path)

          if relative then
            path = relative
          end

          -- Truncate long paths so the date column stays aligned.
          if vim.fn.strdisplaywidth(path) > path_width then
            path = '…' .. path:sub(-(path_width - 1))
          end

          return {
            path = item.path,
            text = string.format('%-' .. path_width .. 's%s%s', path, separator, modified),
          }
        end, items_to_show)

        pick.default_show(buf_id, display_items, query)
      end,
    },
  })
end, { desc = 'visits - recent' })
