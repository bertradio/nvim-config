--    ╭────────────────────────────╮
--    │       statusline.lua       │
--    ╰────────────────────────────╯
--
-- Core Neovim statusline and buffer tabline.
-- No lualine, bufferline, heirline, or mini.statusline required.
-- 07/14/26 - Code from ChatGPT to emulate lualine entirely from core
-- 10/08/26 - Set right to display number of works for md and txt and file
--            size for everything else

--    ╭────────────────────────────────────────────────────────╮
--    │    To make changes in components, search for Future    │
--    ╰────────────────────────────────────────────────────────╯
--

local api = vim.api
local fn = vim.fn

local sep_right = ''
local sep_left = ''

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- General helpers
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function escape_statusline(text)
  return tostring(text or ''):gsub('%%', '%%%%')
end

local function current_statusline_win()
  local winid = tonumber(vim.g.statusline_winid)

  if winid and api.nvim_win_is_valid(winid) then
    return winid
  end

  return api.nvim_get_current_win()
end

local function add_component(parts, text, highlight)
  if not text or text == '' then
    return false
  end

  if highlight then
    parts[#parts + 1] = '%#' .. highlight .. '#'
  end

  parts[#parts + 1] = ' ' .. escape_statusline(text) .. ' '

  return true
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Mode
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local mode_names = {
  n = 'NORMAL',
  no = 'O-PENDING',
  nov = 'O-PENDING',
  noV = 'O-PENDING',
  ['no\22'] = 'O-PENDING',

  niI = 'NORMAL',
  niR = 'NORMAL',
  niV = 'NORMAL',
  nt = 'NORMAL',
  ntT = 'NORMAL',

  v = 'VISUAL',
  V = 'V-LINE',
  ['\22'] = 'V-BLOCK',

  s = 'SELECT',
  S = 'S-LINE',
  ['\19'] = 'S-BLOCK',

  i = 'INSERT',
  ic = 'INSERT',
  ix = 'INSERT',

  R = 'REPLACE',
  Rc = 'REPLACE',
  Rx = 'REPLACE',
  Rv = 'V-REPLACE',
  Rvc = 'V-REPLACE',
  Rvx = 'V-REPLACE',

  c = 'COMMAND',
  cv = 'EX',
  ce = 'EX',

  r = 'PROMPT',
  rm = 'MORE',
  ['r?'] = 'CONFIRM',

  ['!'] = 'SHELL',
  t = 'TERMINAL',
}

local mode_groups = {
  n = 'CoreModeNormal',

  v = 'CoreModeVisual',
  V = 'CoreModeVisual',
  ['\22'] = 'CoreModeVisual',

  s = 'CoreModeVisual',
  S = 'CoreModeVisual',
  ['\19'] = 'CoreModeVisual',

  i = 'CoreModeInsert',
  R = 'CoreModeReplace',
  c = 'CoreModeCommand',
  t = 'CoreModeTerminal',
}

local mode_separator_groups = {
  n = 'CoreModeNormalSep',

  v = 'CoreModeVisualSep',
  V = 'CoreModeVisualSep',
  ['\22'] = 'CoreModeVisualSep',

  s = 'CoreModeVisualSep',
  S = 'CoreModeVisualSep',
  ['\19'] = 'CoreModeVisualSep',

  i = 'CoreModeInsertSep',
  R = 'CoreModeReplaceSep',
  c = 'CoreModeCommandSep',
  t = 'CoreModeTerminalSep',
}

local mode_suffixes = {
  n = 'Normal',

  v = 'Visual',
  V = 'Visual',
  ['\22'] = 'Visual',

  s = 'Visual',
  S = 'Visual',
  ['\19'] = 'Visual',

  i = 'Insert',
  R = 'Replace',
  c = 'Command',
  t = 'Terminal',
}

local function mode_name()
  return mode_names[api.nvim_get_mode().mode] or 'NORMAL'
end

local function mode_highlight()
  local mode = api.nvim_get_mode().mode:sub(1, 1)
  return mode_groups[mode] or 'CoreModeNormal'
end

local function mode_separator_highlight()
  local mode = api.nvim_get_mode().mode:sub(1, 1)
  return mode_separator_groups[mode] or 'CoreModeNormalSep'
end

local function mode_suffix()
  local mode = api.nvim_get_mode().mode:sub(1, 1)
  return mode_suffixes[mode] or 'Normal'
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline component functions
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function short_cwd(context)
  local ok_cwd, cwd = pcall(api.nvim_win_call, context.winid, fn.getcwd)

  if Myfn and type(Myfn.short_cwd) == 'function' then
    local ok, result = pcall(Myfn.short_cwd, {
      cwd = ok_cwd and cwd or nil,
    })

    if ok and result and result ~= '' then
      return result
    end
  end

  return fn.fnamemodify(ok_cwd and cwd or fn.getcwd(), ':~')
end

-- for macro recording indicator
local function recording_status()
  local register = fn.reg_recording()

  if register == '' then
    return ''
  end

  return 'Recording @' .. register
end

-- for spellcheck status if on
local function spell_status(context)
  local ok, enabled = pcall(api.nvim_get_option_value, 'spell', {
    win = context.winid,
  })

  if ok and enabled then
    return 's+'
  end

  return ''
end

local word_cache = {}

local function word_status(context)
  if not api.nvim_win_is_valid(context.winid) then
    return ''
  end

  local mode = api.nvim_get_mode().mode:sub(1, 1)

  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' and word_cache[context.bufnr] then
    return word_cache[context.bufnr]
  end

  local ok, count = pcall(api.nvim_win_call, context.winid, function()
    return fn.wordcount()
  end)

  if not ok or not count then
    return ''
  end

  -- for words indicator on right
  if count.visual_words then
    return tostring(count.visual_words) .. ' Words selected'
  end

  local result = tostring(count.words or 0) .. ' Words'
  word_cache[context.bufnr] = result
  return result
end

local function format_file_size(bytes)
  local units = { 'B', 'KB', 'MB', 'GB', 'TB' }
  local unit = 1
  local size = bytes

  while size >= 1024 and unit < #units do
    size = size / 1024
    unit = unit + 1
  end

  if unit == 1 then
    return string.format('%d %s', size, units[unit])
  end

  return string.format('%.1f %s', size, units[unit])
end

local function file_size_status(context)
  local name = api.nvim_buf_get_name(context.bufnr)
  local extension = fn.fnamemodify(name, ':e'):lower()

  if extension == 'txt' or extension == 'md' then -- words for filetypes
    return word_status(context)
  end

  local size = name ~= '' and fn.getfsize(name) or -1

  if size < 0 then
    return ''
  end

  return format_file_size(size)
end

local function diagnostic_count(context, severity, prefix)
  if context.diagnostic_counts == nil then
    local ok, counts = pcall(vim.diagnostic.count, context.bufnr)
    context.diagnostic_counts = ok and counts or false
  end

  if not context.diagnostic_counts then
    return ''
  end

  local count = context.diagnostic_counts[severity] or 0
  return count > 0 and prefix .. count or ''
end

local function error_status(context)
  return diagnostic_count(context, vim.diagnostic.severity.ERROR, 'E')
end

local function warning_status(context)
  return diagnostic_count(context, vim.diagnostic.severity.WARN, 'W')
end

local diagnostic_gap = '%#StatusLine#  '

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline component configuration
--
-- Future statusline additions or removals normally belong here.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Left side
local left_components = {
  {
    value = mode_name, -- NORMAL, INSERT, etc
    highlight = mode_highlight,

    separator_after = function()
      return '%#' .. mode_separator_highlight() .. '#' .. sep_right
    end,
  },

  {
    value = short_cwd, -- current path shortened
    highlight = 'CoreStatusCwd',
  },
}

-- Right side
local right_components = {
  {
    value = recording_status, -- macro recording on
    highlight = 'CoreStatusRecording',
  },

  {
    value = spell_status, -- spellcheck on
    highlight = 'CoreStatusInfo',

    separator_after = function()
      return diagnostic_gap
    end,
  },

  {
    value = error_status, -- current-buffer errors
    highlight = 'CoreStatusError',

    separator_after = function(context)
      return warning_status(context) == '' and diagnostic_gap or ''
    end,
  },

  {
    value = warning_status, -- current-buffer warnings
    highlight = 'CoreStatusWarning',

    separator_after = function()
      return diagnostic_gap
    end,
  },

  {
    value = file_size_status, -- words for text/Markdown; file size otherwise

    highlight = function()
      return 'CoreStatusWords' .. mode_suffix()
    end,

    separator_before = function()
      return '%#CoreWordsSep' .. mode_suffix() .. '#' .. sep_left
    end,
  },
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline renderer
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function component_value(component, context)
  if type(component.value) == 'function' then
    local ok, value = pcall(component.value, context)

    if ok then
      return value
    end

    return ''
  end

  return component.value or ''
end

local function component_highlight(component, context)
  if type(component.highlight) == 'function' then
    local ok, highlight = pcall(component.highlight, context)

    if ok then
      return highlight
    end

    return nil
  end

  return component.highlight
end

local function render_components(components, context)
  local result = {}

  for _, component in ipairs(components) do
    local text = component_value(component, context)

    if text and text ~= '' then
      if component.separator_before then
        local ok, separator = pcall(component.separator_before, context)

        if ok and separator then
          result[#result + 1] = separator
        end
      end

      add_component(result, text, component_highlight(component, context))

      if component.separator_after then
        local ok, separator = pcall(component.separator_after, context)

        if ok and separator then
          result[#result + 1] = separator
        end
      end
    end
  end

  return table.concat(result)
end

function _G.CoreStatusline()
  local winid = current_statusline_win()
  local bufnr = api.nvim_win_get_buf(winid)

  local context = {
    winid = winid,
    bufnr = bufnr,
  }

  return render_components(left_components, context)
    .. '%#StatusLine#'
    .. '%='
    .. render_components(right_components, context)
    .. '%#StatusLine#'
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Buffer tabline helpers
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function listed_buffers()
  local buffers = {}

  for _, info in ipairs(fn.getbufinfo({ buflisted = 1 })) do
    if api.nvim_buf_is_valid(info.bufnr) then
      buffers[#buffers + 1] = info.bufnr
    end
  end

  return buffers
end

local function buffer_name(bufnr)
  local name = api.nvim_buf_get_name(bufnr)

  if name == '' then
    return '[No Name]'
  end

  local tail = fn.fnamemodify(name, ':t')

  if tail == '' then
    return '[No Name]'
  end

  return tail
end

local function duplicate_names(buffers)
  local counts = {}

  for _, bufnr in ipairs(buffers) do
    local name = buffer_name(bufnr)
    counts[name] = (counts[name] or 0) + 1
  end

  return counts
end

local function buffer_label(bufnr, duplicates)
  local label = buffer_name(bufnr)

  -- Add the parent directory when names are duplicated.
  if duplicates[label] and duplicates[label] > 1 then
    local path = api.nvim_buf_get_name(bufnr)
    local parent = fn.fnamemodify(path, ':h:t')

    if parent ~= '' and parent ~= '.' then
      label = parent .. '/' .. label
    end
  end

  if fn.strdisplaywidth(label) > 38 then
    label = fn.strcharpart(label, 0, 35) .. '…'
  end

  if vim.bo[bufnr].modified then
    label = label .. ' ●'
  end

  return label
end

local function tab_group(index, bufnr, current)
  if bufnr == current then
    return 'CoreTabSel' .. mode_suffix()
  end

  if index % 2 == 0 then
    return 'CoreTabEven'
  end

  return 'CoreTabOdd'
end

local function tab_transition_group(from_group, to_group)
  return from_group .. 'To' .. to_group
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Buffer click handling
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function _G.CoreBufferClick(bufnr, _, button, _)
  bufnr = tonumber(bufnr)

  if not bufnr or not api.nvim_buf_is_valid(bufnr) then
    return
  end

  if button == 'l' then
    api.nvim_set_current_buf(bufnr)
    return
  end

  -- Middle-click closes an unmodified buffer.
  if button == 'm' then
    if vim.bo[bufnr].modified then
      vim.notify('Buffer has unsaved changes: ' .. buffer_name(bufnr), vim.log.levels.WARN)
      return
    end

    pcall(api.nvim_buf_delete, bufnr, {})
  end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Buffer tabline
--
-- Each buffer begins with one Powerline arrow:
--
--   previous background → current buffer background
--
-- There is no separate trailing arrow.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function _G.CoreTabline()
  local buffers = listed_buffers()

  if #buffers == 0 then
    return ''
  end

  local current = api.nvim_get_current_buf()
  local duplicates = duplicate_names(buffers)
  local labels = {}
  local widths = {}
  local result = {}

  local current_index = 1

  for index, bufnr in ipairs(buffers) do
    labels[index] = buffer_label(bufnr, duplicates)
    local label_padding = bufnr == current and 1 or 2
    widths[index] = fn.strdisplaywidth(labels[index]) + 1 + label_padding -- arrow and label padding

    if bufnr == current then
      current_index = index
    end
  end

  -- Keep a contiguous group around the active buffer within the UI width.
  local first = current_index
  local last = current_index
  local max_width = math.max(vim.o.columns, 1)

  local function visible_width(from, to)
    local width = 1 -- final transition arrow

    for index = from, to do
      width = width + widths[index]
    end

    if from > 1 then
      width = width + 2 -- leading ellipsis and space
    end

    if to < #buffers then
      width = width + 2 -- trailing ellipsis and space
    end

    return width
  end

  local distance = 1

  while first > 1 or last < #buffers do
    local changed = false
    local left = current_index - distance
    local right = current_index + distance

    if left >= 1 and visible_width(left, last) <= max_width then
      first = left
      changed = true
    end

    if right <= #buffers and visible_width(first, right) <= max_width then
      last = right
      changed = true
    end

    if not changed then
      break
    end

    distance = distance + 1
  end

  local previous_group = 'CoreTabFill'

  if first > 1 then
    result[#result + 1] = '%#CoreTabFill# …'
  end

  for index = first, last do
    local bufnr = buffers[index]
    local current_group = tab_group(index, bufnr, current)
    local transition = tab_transition_group(previous_group, current_group)

    -- Make the leading arrow and label one click target.
    result[#result + 1] = '%' .. bufnr .. '@v:lua.CoreBufferClick@'

    -- Leading arrow.
    result[#result + 1] = '%#' .. transition .. '#' .. sep_right

    -- The selected tab omits the trailing cell so its mode-colored background
    -- ends directly at the transition arrow.
    local trailing_space = bufnr == current and '' or ' '
    result[#result + 1] = '%#'
      .. current_group
      .. '# '
      .. escape_statusline(labels[index])
      .. trailing_space

    result[#result + 1] = '%T'

    previous_group = current_group
  end

  local last_group = tab_group(last, buffers[last], current)

  local final_transition = tab_transition_group(last_group, 'CoreTabFill')

  result[#result + 1] = '%#' .. final_transition .. '#' .. sep_right

  result[#result + 1] = '%#CoreTabFill#'

  if last < #buffers then
    result[#result + 1] = ' …'
  end

  result[#result + 1] = '%='
  return table.concat(result)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Highlight groups
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function set_highlights()
  local function get_hl(name)
    local ok, hl = pcall(api.nvim_get_hl, 0, {
      name = name,
      link = false,
    })

    return ok and hl or {}
  end

  local function color(name, attribute, fallback)
    local hl = get_hl(name)
    return hl[attribute] or fallback
  end

  local normal = get_hl('Normal')
  local statusline = get_hl('StatusLine')
  local tabline = get_hl('TabLine')

  local normal_bg = normal.bg or 0x1e1e2e
  local normal_fg = normal.fg or 0xcdd6f4

  local status_bg = statusline.bg or color('StatusLineNC', 'bg', normal_bg)

  local status_fg = statusline.fg or normal_fg

  local mode_normal_bg = color('Function', 'fg', 0x89b4fa)

  local mode_insert_bg = color('String', 'fg', 0xa6e3a1)

  local mode_visual_bg = color('Keyword', 'fg', 0xcba6f7)

  local mode_replace_bg = color('DiagnosticError', 'fg', 0xf38ba8)

  local mode_command_bg = color('DiagnosticWarn', 'fg', 0xf9e2af)

  local mode_terminal_bg = color('Type', 'fg', 0x94e2d5)

  local mode_colors = {
    Normal = mode_normal_bg,
    Insert = mode_insert_bg,
    Visual = mode_visual_bg,
    Replace = mode_replace_bg,
    Command = mode_command_bg,
    Terminal = mode_terminal_bg,
  }

  local cwd_bg = color('CursorLine', 'bg', status_bg)

  local error_bg = color('DiagnosticError', 'fg', 0xf38ba8)

  local warning_bg = color('DiagnosticWarn', 'fg', 0xf9e2af)

  local recording_bg = warning_bg

  local info_bg = color('Type', 'fg', 0x94e2d5)

  -- Mode blocks.
  api.nvim_set_hl(0, 'CoreModeNormal', {
    fg = normal_bg,
    bg = mode_normal_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreModeInsert', {
    fg = normal_bg,
    bg = mode_insert_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreModeVisual', {
    fg = normal_bg,
    bg = mode_visual_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreModeReplace', {
    fg = normal_bg,
    bg = mode_replace_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreModeCommand', {
    fg = normal_bg,
    bg = mode_command_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreModeTerminal', {
    fg = normal_bg,
    bg = mode_terminal_bg,
    bold = true,
  })

  -- Mode separators.
  api.nvim_set_hl(0, 'CoreModeNormalSep', {
    fg = mode_normal_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreModeInsertSep', {
    fg = mode_insert_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreModeVisualSep', {
    fg = mode_visual_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreModeReplaceSep', {
    fg = mode_replace_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreModeCommandSep', {
    fg = mode_command_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreModeTerminalSep', {
    fg = mode_terminal_bg,
    bg = cwd_bg,
  })

  api.nvim_set_hl(0, 'CoreStatusCwd', {
    fg = normal_fg,
    bg = cwd_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreStatusRecording', {
    fg = normal_bg,
    bg = recording_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreStatusInfo', {
    fg = normal_bg,
    bg = info_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreStatusError', {
    fg = normal_bg,
    bg = error_bg,
    bold = true,
  })

  api.nvim_set_hl(0, 'CoreStatusWarning', {
    fg = normal_bg,
    bg = warning_bg,
    bold = true,
  })

  -- Word count follows the current mode.
  for suffix, background in pairs(mode_colors) do
    api.nvim_set_hl(0, 'CoreWordsSep' .. suffix, {
      fg = background,
      bg = status_bg,
    })

    api.nvim_set_hl(0, 'CoreStatusWords' .. suffix, {
      fg = normal_bg,
      bg = background,
      bold = true,
    })
  end

  -- Tabline colors.
  local inactive_odd_bg = color('CursorLine', 'bg', status_bg)

  local inactive_even_bg = color('Visual', 'bg', status_bg)

  local fill_bg = tabline.bg or status_bg

  -- set font color for inactive tabs font``
  -- local tab_fg = tabline.fg or color('Comment', 'fg', status_fg)
  -- local tab_fg = normal_fg
  local tab_fg = status_fg

  api.nvim_set_hl(0, 'CoreTabOdd', {
    fg = tab_fg,
    bg = inactive_odd_bg,
  })

  api.nvim_set_hl(0, 'CoreTabEven', {
    fg = tab_fg,
    bg = inactive_even_bg,
  })

  api.nvim_set_hl(0, 'CoreTabFill', {
    fg = tab_fg,
    bg = fill_bg,
  })

  -- The active buffer follows the current mode.
  for suffix, background in pairs(mode_colors) do
    api.nvim_set_hl(0, 'CoreTabSel' .. suffix, {
      fg = normal_bg,
      bg = background,
      bold = true,
    })
  end

  -- Backgrounds used to construct the leading arrows.
  local tab_backgrounds = {
    CoreTabFill = fill_bg,
    CoreTabOdd = inactive_odd_bg,
    CoreTabEven = inactive_even_bg,
  }

  for suffix, background in pairs(mode_colors) do
    tab_backgrounds['CoreTabSel' .. suffix] = background
  end

  -- A right-pointing Powerline arrow uses:
  --
  --   foreground = previous tab background
  --   background = current tab background
  for from_group, from_bg in pairs(tab_backgrounds) do
    for to_group, to_bg in pairs(tab_backgrounds) do
      api.nvim_set_hl(0, tab_transition_group(from_group, to_group), {
        fg = from_bg,
        bg = to_bg,
      })
    end
  end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Options
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.o.statusline = '%!v:lua.CoreStatusline()'
vim.o.tabline = '%!v:lua.CoreTabline()'

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Refresh events
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local group = api.nvim_create_augroup('CoreStatusline', {
  clear = true,
})

-- redraw status and tabline after delete buffer
local redraw_pending = false

local function redraw()
  if redraw_pending then
    return
  end

  redraw_pending = true

  vim.schedule(function()
    redraw_pending = false
    vim.cmd.redrawstatus()
    vim.cmd.redrawtabline()
  end)
end

-- Word counting can be noticeable in large buffers. Keep the previous value
-- while text is changing, then refresh it shortly after typing stops.
local word_refresh_generation = {}

local function schedule_word_refresh(event)
  local bufnr = event.buf
  local generation = (word_refresh_generation[bufnr] or 0) + 1
  word_refresh_generation[bufnr] = generation

  vim.defer_fn(function()
    if word_refresh_generation[bufnr] ~= generation then
      return
    end

    word_cache[bufnr] = nil
    redraw()
  end, 150)
end

api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function()
    set_highlights()
    redraw()
  end,
})

api.nvim_create_autocmd({
  'BufAdd',
  'BufDelete',
  'BufEnter',
  'BufFilePost',
  'BufWritePost',
  'DiagnosticChanged',
  'DirChanged',
  'ModeChanged',
  'RecordingEnter',
  'RecordingLeave',
  'WinEnter',
}, {
  group = group,
  callback = redraw,
})

api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = group,
  callback = schedule_word_refresh,
})

api.nvim_create_autocmd({ 'BufDelete', 'BufReadPost' }, {
  group = group,
  callback = function(event)
    word_cache[event.buf] = nil
    word_refresh_generation[event.buf] = nil
  end,
})

api.nvim_create_autocmd('OptionSet', {
  group = group,
  pattern = 'spell',
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

set_highlights()
