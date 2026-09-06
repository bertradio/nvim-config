--    ╭────────────────────────────╮
--    │    mini-statusline.lua     │
--    ╰────────────────────────────╯

-- mini.nvim is already installed in the user's configuration.
local statusline = require('mini.statusline')

-- Catppuccin Mocha colors, matching Lualine's catppuccin-nvim theme.
local colors = {
  base = '#1e1e2e',
  surface0 = '#313244',
  surface1 = '#45475a',
  text = '#cdd6f4',
  blue = '#89b4fa',
  green = '#a6e3a1',
  mauve = '#cba6f7',
  red = '#f38ba8',
  peach = '#fab387',
  yellow = '#f9e2af',
  orange = '#FFA500',
}

local function mode_color()
  local mode = vim.fn.mode(1):sub(1, 1)
  if mode == 'i' then
    return colors.green
  end
  if mode == 'v' or mode == 'V' or mode == '\22' then
    return colors.mauve
  end
  if mode == 'R' then
    return colors.red
  end
  if mode == 'c' then
    return colors.peach
  end
  return colors.blue
end

local function set_highlights()
  local accent = mode_color()

  -- Statusline sections and their pointed transitions.
  vim.api.nvim_set_hl(0, 'MiniSLMode', { fg = colors.base, bg = accent, bold = true })
  vim.api.nvim_set_hl(0, 'MiniSLModeToInfo', { fg = accent, bg = colors.surface0 })
  vim.api.nvim_set_hl(0, 'MiniSLInfo', { fg = colors.text, bg = colors.surface0 })
  vim.api.nvim_set_hl(0, 'MiniSLInfoToBase', { fg = colors.surface0, bg = colors.base })
  vim.api.nvim_set_hl(0, 'MiniSLBaseToInfo', { fg = colors.surface0, bg = colors.base })
  vim.api.nvim_set_hl(0, 'MiniSLInfoToMode', { fg = accent, bg = colors.surface0 })
  vim.api.nvim_set_hl(0, 'MiniSLRecording', { fg = colors.orange, bg = colors.base })

  -- mini.tabline equivalents of Lualine's use_mode_colors=true.
  vim.api.nvim_set_hl(0, 'MiniTablineCurrent', { fg = colors.base, bg = accent, bold = true })
  vim.api.nvim_set_hl(
    0,
    'MiniTablineModifiedCurrent',
    { fg = colors.base, bg = accent, bold = true, italic = true }
  )
  vim.api.nvim_set_hl(0, 'MiniTablineVisible', { fg = colors.text, bg = colors.surface1 })
  vim.api.nvim_set_hl(0, 'MiniTablineModifiedVisible', { fg = colors.yellow, bg = colors.surface1 })
  vim.api.nvim_set_hl(0, 'MiniTablineHidden', { fg = colors.text, bg = colors.surface0 })
  vim.api.nvim_set_hl(0, 'MiniTablineModifiedHidden', { fg = colors.yellow, bg = colors.surface0 })
  vim.api.nvim_set_hl(0, 'MiniTablineFill', { bg = colors.base })
  vim.api.nvim_set_hl(0, 'MiniTablineCurrentSep', { fg = accent, bg = colors.base })
  vim.api.nvim_set_hl(0, 'MiniTablineVisibleSep', { fg = colors.surface1, bg = colors.base })
  vim.api.nvim_set_hl(0, 'MiniTablineHiddenSep', { fg = colors.surface0, bg = colors.base })
end

-- Number of words in the buffer (kept here if you want to re-enable it).
local function get_words()
  local wc = vim.fn.wordcount()
  if wc.visual_words then
    return wc.visual_words .. ' Words selected'
  end
  return wc.words .. ' Words'
end

local function short_cwd()
  if Myfn and type(Myfn.short_cwd) == 'function' then
    return Myfn.short_cwd()
  end
  return statusline.section_git({ trunc_width = 40 })
end

local function spell_on()
  return vim.wo.spell and 's+' or ''
end

local function macro_recording()
  local register = vim.fn.reg_recording()
  return register == '' and '' or ('Recording @' .. register)
end

local function search_count()
  if vim.v.hlsearch == 0 then
    return ''
  end

  local ok, count = pcall(vim.fn.searchcount, {
    recompute = 1,
    maxcount = 999,
    timeout = 500,
  })
  if not ok or count.total == 0 then
    return ''
  end

  local current = count.current > count.maxcount and ('>' .. count.maxcount) or count.current
  local total = count.total > count.maxcount and ('>' .. count.maxcount) or count.total
  return current .. '/' .. total
end

local function file_size()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' or vim.bo.buftype ~= '' then
    return ''
  end

  local bytes = vim.fn.getfsize(name)
  if bytes < 0 then
    return ''
  end

  local units = { 'B', 'KB', 'MB', 'GB' }
  local unit = 1
  while bytes >= 1024 and unit < #units do
    bytes = bytes / 1024
    unit = unit + 1
  end

  if unit == 1 then
    return bytes .. units[unit]
  end
  return string.format('%.1f%s', bytes, units[unit])
end

local function active_content()
  local mode = statusline.section_mode({ trunc_width = 120 })
  local cwd = short_cwd()
  local recording = macro_recording()
  local middle = table.concat(
    vim.tbl_filter(function(x)
      return x ~= ''
    end, {
      spell_on(),
      search_count(),
    }),
    ' '
  )
  local size = file_size()

  -- Escape user/file-derived percent signs before placing them in statusline syntax.
  local function esc(text)
    return tostring(text):gsub('%%', '%%%%')
  end

  local left = '%#MiniSLMode# '
    .. esc(mode)
    .. '%#MiniSLModeToInfo#'
    .. '%#MiniSLInfo# '
    .. esc(cwd)
    .. ' '
    .. '%#MiniSLInfoToBase#'

  local right = ''
  if recording ~= '' then
    right = right .. '%#MiniSLRecording# ' .. esc(recording) .. ' '
  end
  if middle ~= '' then
    right = right .. '%#MiniSLBaseToInfo#' .. '%#MiniSLInfo# ' .. esc(middle) .. ' '
  end
  -- Do not draw the final pointer when an unnamed/non-file buffer has no size.
  if size ~= '' then
    right = right .. '%#MiniSLInfoToMode#' .. '%#MiniSLMode# ' .. esc(size) .. ' '
  end

  return left .. '%<%=' .. right
end

statusline.setup({
  content = {
    active = active_content,
  },
  set_vim_settings = true, -- Includes laststatus=3 for a global statusline.
})

set_highlights()

-- Redraw immediately when macro recording starts or stops.
local group = vim.api.nvim_create_augroup('MiniStatuslineRecording', { clear = true })
vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  group = group,
  callback = function()
    vim.cmd('redrawstatus')
  end,
})

-- Update mode-colored sections immediately and restore them after colorscheme changes.
vim.api.nvim_create_autocmd({ 'ModeChanged', 'ColorScheme' }, {
  group = group,
  callback = function()
    set_highlights()
    vim.cmd('redrawstatus')
    vim.cmd('redrawtabline')
  end,
})

-- A core tabline is used here because mini.tabline's `format` result is plain
-- label text; it cannot contain a separately highlighted Powerline separator.
-- These global functions are required because 'tabline' evaluates them by name.
function _G.MiniBufferTablineClick(buf_id)
  if vim.api.nvim_buf_is_valid(buf_id) then
    vim.api.nvim_set_current_buf(buf_id)
  end
end

function _G.MiniBufferTabline()
  local result = {}
  local current = vim.api.nvim_get_current_buf()

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      local name = vim.api.nvim_buf_get_name(buf_id)
      local label = name == '' and '[No Name]' or vim.fn.fnamemodify(name, ':t')
      label = vim.fn.strcharpart(label, 0, 40):gsub('%%', '%%%%')

      local is_current = buf_id == current
      local is_visible = vim.fn.bufwinid(buf_id) ~= -1
      local modified = vim.bo[buf_id].modified
      local item_hl
      local separator_hl

      if is_current then
        item_hl = modified and 'MiniTablineModifiedCurrent' or 'MiniTablineCurrent'
        separator_hl = 'MiniTablineCurrentSep'
      elseif is_visible then
        item_hl = modified and 'MiniTablineModifiedVisible' or 'MiniTablineVisible'
        separator_hl = 'MiniTablineVisibleSep'
      else
        item_hl = modified and 'MiniTablineModifiedHidden' or 'MiniTablineHidden'
        separator_hl = 'MiniTablineHiddenSep'
      end

      if modified then
        label = label .. ' ●'
      end

      result[#result + 1] = '%'
        .. buf_id
        .. '@v:lua.MiniBufferTablineClick@'
        .. '%#'
        .. item_hl
        .. '# '
        .. label
        .. ' '
        .. '%#'
        .. separator_hl
        .. '#%X'
    end
  end

  result[#result + 1] = '%#MiniTablineFill#%='
  return table.concat(result)
end

vim.o.showtabline = 2
vim.o.tabline = '%!v:lua.MiniBufferTabline()'
