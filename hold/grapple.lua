-- lua/plugins/grapple.lua
-- Converted to vim.pack.add 4-3-26
-- Code from ChatGPT to customize

-- vim.pack.add({
--   { src = 'https://github.com/nvim-lua/plenary.nvim' },
--   { src = 'https://github.com/cbochs/grapple.nvim' },
-- })

local g = require('grapple')

g.setup({
  scope = 'global',
  icons = true,
})

-- ---------- helpers ----------
local function tags()
  return g.tags() or {}
end
local function shorten(p)
  return vim.fn.fnamemodify(p, ':~:.'):gsub('\\', '/')
end

local function open_by_index(n)
  local t = tags()[n]
  if not t then
    return
  end
  pcall(function()
    g.select({ path = t.path })
  end)
end

local function delete_by_index(n)
  local t = tags()[n]
  if not t then
    return false
  end
  local ok = pcall(function()
    g.untag({ path = t.path })
  end)
  if ok then
    vim.notify('Removed ' .. shorten(t.path) .. ' from grapple menu', vim.log.levels.INFO)
    return true
  end
  vim.notify('Failed to remove tag', vim.log.levels.WARN)
  return false
end

local function render_lines(list)
  local lines, maxlen = {}, 0
  for _, t in ipairs(list) do
    local s = '  ' .. shorten(t.path)
    lines[#lines + 1] = s
    if #s > maxlen then
      maxlen = #s
    end
  end
  return lines, maxlen
end

local function clamp(v, a, b)
  return math.max(a, math.min(b, v))
end

-- ---------- menu (recreate window on every delete) ----------
local function grapple_menu_short_paths(start_row)
  local list = tags()
  if #list == 0 then
    vim.notify('nothing in menu ', vim.log.levels.INFO)
    return
  end

  local lines, maxlen = render_lines(list)

  -- fresh scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'grapplemenu'

  -- compute size + position
  local width = clamp(maxlen + 4, 40, math.max(100, math.min(80, vim.o.columns - 8)))
  local height = clamp(#lines, 1, 15)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  -- fresh window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = '  <CR> Open - <C-d> Delete  ',
    title_pos = 'center',
  })

  local function win_alive()
    return win and vim.api.nvim_win_is_valid(win)
  end
  local function close_win()
    if win_alive() then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  local function cur_row()
    if not win_alive() then
      return 1
    end
    return vim.api.nvim_win_get_cursor(win)[1]
  end
  local function set_row(r)
    if win_alive() then
      vim.api.nvim_win_set_cursor(win, { r, 0 })
    end
  end

  -- place cursor (requested starting row, clamped)
  set_row(clamp(start_row or 1, 1, #lines))

  -- open: <CR>
  vim.keymap.set('n', '<CR>', function()
    local n = cur_row()
    close_win()
    vim.schedule(function()
      open_by_index(n)
    end)
  end, { buffer = buf, nowait = true, silent = true })

  -- delete: <C-d> → delete + fully recreate menu with new size
  vim.keymap.set('n', '<C-d>', function()
    local n = cur_row()
    if delete_by_index(n) then
      vim.schedule(function()
        -- rebuild: close current window and reopen with updated list/size
        close_win()
        local new_list = tags()
        if #new_list == 0 then
          return
        end
        -- reopen menu keeping cursor on the same row index if possible
        grapple_menu_short_paths(n)
      end)
    end
  end, { buffer = buf, nowait = true, silent = true })

  -- quit: q / Esc
  for _, k in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', k, close_win, { buffer = buf, nowait = true, silent = true })
  end
end

-- ---------- keymaps ----------
vim.keymap.set('n', '<Leader>ha', g.tag, { desc = 'tag current file' })
vim.keymap.set('n', '<Leader>hd', g.untag, { desc = 'untag current file' })

-- menu: <CR>=open, <C-d>=delete, auto-recreate on delete (box resizes)
vim.keymap.set('n', '<Leader>hh', function()
  grapple_menu_short_paths()
end, { desc = 'menu' })
