--    ╭────────────────────────────╮
--    │          oil.lua           │
--    ╰────────────────────────────╯

-- vim.pack version of old lazy.nvim oil config
-- changed from lazy to vim.pack 3-30-26
-- 04/28/26:
--        simplified code
--        removed indicators of changed oil buffer - no longer worked
--        removed float shortcut
--        Gemini optimized for full-screen and quick startup
-- 09/26/26 - Optimizations and corrections to exclude and dirchanged from Codex
-- 10/26/26 - Float shortcut restored (<Leader>-) with preview, float options merged,
--            DirChanged follows cwd in floats too, snacks rename hook restored,
--            pending-change indicator (red float border / winbar) re-added

vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
})

local detail = false
local file_exclude = require('file_exclude')
local group = vim.api.nvim_create_augroup('OilConfig', { clear = true })

-- Keymaps to start oil
Kset('n', '=', '<cmd>Oil .<cr>', { desc = 'Oil full screen' })
Kset('n', '-', function()
  require('oil').open_float(vim.fn.getcwd(), { preview = {} })
end, { desc = 'Oil float (with preview, cwd)' })

-- set up oil
-- stylua: ignore
require('oil').setup({
  delete_to_trash               = true,
  skip_confirm_for_simple_edits = true,

  -- Rounded border for :w dialogs
  confirmation = {
    border       = 'rounded',
    win_options  = { winblend = 0 },
  },

  win_options = {
    wrap = true,
  },

  -- Float window (used by <Leader>-)
  float = {
    padding     = 3,
    max_width   = 0.9,
    max_height  = 0,
    border      = 'double',
    win_options = { winblend = 0 },
  },

  keymaps = {
    ['<ESC>'] = 'actions.close',
    ['q']     = 'actions.close',
    ['<CR>']  = 'actions.select',
    ['<BS>']  = 'actions.parent',
    ['g.']    = 'actions.toggle_hidden',
    ['<C-c>'] = 'actions.close',
    ['<C-q>'] = '<cmd>bd!<cr>',
    ['gd']    = {
      desc = 'Toggle file detail view',
      callback = function()
        local next_detail = not detail
        local has_modified_buffer = false

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == 'oil' and vim.bo[buf].modified then
            has_modified_buffer = true
            break
          end
        end

        require('oil').set_columns(next_detail and { 'icon', 'size', 'mtime' } or { 'icon' })
        if not has_modified_buffer then detail = next_detail end
      end,
    },
  },

  view_options = {
    case_insensitive = true,
    is_hidden_file   = function(name)
      return vim.startswith(name, '.') or file_exclude.is_excluded(name)
    end,
  },
})

-- Pending-change indicator
-- Float:      border turns red while the Oil buffer has unsaved changes.
-- Full-screen/split: the winbar label turns red (no border to color).
-- Preview windows are never colored, and any red they inherit is cleared.
local function define_highlights()
  vim.api.nvim_set_hl(0, 'OilBorderDirty', { fg = '#ff5555' })
  vim.api.nvim_set_hl(0, 'OilBarDirty', { fg = '#ffffff', bg = '#ff5555', bold = true })
  vim.api.nvim_set_hl(0, 'OilBackdrop', { bg = '#000000' })
end
define_highlights()

-- Dim everything behind an Oil float with a see-through backdrop window.
-- Higher blend = less dim (0 = solid black, 100 = invisible).
local BACKDROP_BLEND = 70
local backdrop_win = nil

local function oil_float_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if
      not vim.w[win].oil_backdrop
      and vim.api.nvim_win_get_config(win).relative ~= ''
      and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'oil'
    then
      return true
    end
  end
  return false
end

local function update_backdrop()
  local exists = backdrop_win and vim.api.nvim_win_is_valid(backdrop_win)
  if not oil_float_open() then
    if exists then
      pcall(vim.api.nvim_win_close, backdrop_win, true)
    end
    backdrop_win = nil
    return
  end

  local size = { width = vim.o.columns, height = vim.o.lines - vim.o.cmdheight }
  if exists then
    vim.api.nvim_win_set_config(backdrop_win, size)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  backdrop_win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    row = 0,
    col = 0,
    width = size.width,
    height = size.height,
    focusable = false,
    style = 'minimal',
    zindex = 40, -- above normal windows, below Oil's float (zindex 50)
    noautocmd = true,
  })
  vim.w[backdrop_win].oil_backdrop = true
  vim.wo[backdrop_win].winblend = BACKDROP_BLEND
  vim.wo[backdrop_win].winhighlight = 'Normal:OilBackdrop'
end

-- Set/clear entries of 'winhighlight' by key, keeping all other entries.
-- map: { Key = 'HlGroup' | false }  (false removes the entry)
local function set_winhl(win, map)
  local parts = {}
  for part in vim.wo[win].winhighlight:gmatch('[^,]+') do
    local key = part:match('^([^:]+):')
    if map[key] == nil then
      table.insert(parts, part)
    end
  end
  for key, hl in pairs(map) do
    if hl then
      table.insert(parts, key .. ':' .. hl)
    end
  end
  vim.wo[win].winhighlight = table.concat(parts, ',')
end

local function refresh_window(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local is_oil = vim.bo[buf].filetype == 'oil'
  local dirty = is_oil and vim.bo[buf].modified
  local winhl = vim.wo[win].winhighlight
  local is_float = vim.api.nvim_win_get_config(win).relative ~= ''

  if is_float then
    -- Oil float, or a window (e.g. preview) that inherited a red border
    if is_oil or winhl:find('OilBorderDirty', 1, true) then
      set_winhl(win, { FloatBorder = dirty and 'OilBorderDirty' or false })
    end
  elseif is_oil then
    -- Only the label text is red; the rest of the bar blends with the buffer
    local fill = dirty and 'Normal' or false
    vim.wo[win].winbar = dirty and '%#OilBarDirty# Oil (modified) %*' or ''
    set_winhl(win, { WinBar = fill, WinBarNC = fill })
  elseif vim.wo[win].winbar:find('OilBarDirty', 1, true) then
    -- non-Oil window that inherited the red winbar
    vim.wo[win].winbar = ''
    set_winhl(win, { WinBar = false, WinBarNC = false })
  end
end

local function refresh_all_indicators()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      refresh_window(win)
    end
  end
  update_backdrop()
end

local function indicator_autocmd(events, pattern)
  return pcall(vim.api.nvim_create_autocmd, events, {
    group = group,
    pattern = pattern,
    callback = function()
      vim.schedule(refresh_all_indicators)
    end,
    desc = 'Oil pending-change indicator',
  })
end

indicator_autocmd({ 'BufWinEnter', 'TextChanged', 'TextChangedI', 'InsertLeave' }, 'oil://*')
-- Not available in every Neovim build, so register it on its own and ignore failure
indicator_autocmd('BufModifiedSet', 'oil://*')
-- New windows (e.g. the preview) can inherit window options; re-check them
indicator_autocmd({ 'WinNew', 'BufWinEnter', 'WinClosed', 'VimResized' }, '*')
indicator_autocmd('FileType', 'oil')

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'OilActionsPost',
  callback = function()
    vim.schedule(refresh_all_indicators)
  end,
  desc = 'Clear Oil indicator after changes are applied',
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = define_highlights,
  desc = 'Re-create Oil indicator highlights',
})

-- Directory sync: every Oil window (full-screen, split, or float) follows cwd.
-- Floats get their preview reopened afterwards.
vim.api.nvim_create_autocmd('DirChanged', {
  group = group,
  callback = function()
    vim.schedule(function()
      local oil = require('oil')
      local cwd = vim.fn.getcwd()
      local curwin = vim.api.nvim_get_current_win()

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
          vim.api.nvim_win_call(win, function()
            oil.open(cwd)
          end)

          if vim.api.nvim_win_get_config(win).relative ~= '' then
            vim.defer_fn(function()
              if not vim.api.nvim_win_is_valid(win) then
                return
              end
              vim.api.nvim_win_call(win, function()
                local entry = oil.get_cursor_entry()
                if entry and entry.type == 'file' then
                  pcall(oil.open_preview, {})
                end
              end)
              if vim.api.nvim_win_is_valid(curwin) then
                vim.api.nvim_set_current_win(curwin)
              end
            end, 30)
          end
        end
      end
    end)
  end,
  desc = 'Make Oil follow Neovim cwd',
})

-- Enable LSP rename-on-move from snacks
vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'OilActionsPost',
  callback = function(event)
    local actions = event.data and event.data.actions
    if actions and actions.type == 'move' and _G.Snacks then
      Snacks.rename.on_rename_file(actions.src_url, actions.dest_url)
    end
  end,
  desc = 'LSP rename on Oil file move',
})

-- Apply the wrap-around mapping only in Oil buffers
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'oil',
  callback = function()
    Kset('n', '<Down>', function()
      if vim.fn.line('.') == vim.fn.line('$') then
        vim.cmd('normal! gg')
      else
        vim.cmd('normal! j')
      end
    end, { buffer = true })

    Kset('n', '<Up>', function()
      if vim.fn.line('.') == 1 then
        vim.cmd('normal! G')
      else
        vim.cmd('normal! k')
      end
    end, { buffer = true })
  end,
})
