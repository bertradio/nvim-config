-- statusline.lua

-- Created: 07/02/26
--

vim.o.laststatus = 3
vim.o.showtabline = 2

local function short_cwd()
  if Myfn and Myfn.short_cwd then
    return Myfn.short_cwd()
  end
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end

local function words()
  local wc = vim.fn.wordcount()
  if wc.visual_words then
    return wc.visual_words .. ' Words selected'
  end
  return wc.words .. ' Words'
end

local function spell()
  return vim.wo.spell and 's+' or ''
end

local function macro()
  local r = vim.fn.reg_recording()
  return r ~= '' and ('Recording @' .. r) or ''
end

local function search_count()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local ok, sc = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
  if not ok or sc.total == 0 then
    return ''
  end
  return string.format('%d/%d', sc.current, sc.total)
end

function _G.MyStatusline()
  local right = table.concat(
    vim.tbl_filter(function(s)
      return s and s ~= ''
    end, {
      macro(),
      spell(),
      search_count(),
      words(),
    }),
    '  '
  )

  return table.concat({
    ' ',
    short_cwd(),
    ' %m',
    '%=',
    right,
    ' ',
  })
end

vim.o.statusline = '%!v:lua.MyStatusline()'

local function buf_label(buf)
  local name = vim.api.nvim_buf_get_name(buf)

  if vim.bo[buf].filetype == 'oil' then
    name = name:gsub('^oil://', ''):gsub('^oil%-trash://', '')
    return 'Oil: ' .. vim.fn.fnamemodify(name, ':~')
  end

  if name == '' then
    return '[No Name]'
  end

  return vim.fn.fnamemodify(name, ':t')
end

function _G.MyTabline()
  local s = ''

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local current = buf == vim.api.nvim_get_current_buf()
      local hl = current and '%#TabLineSel#' or '%#TabLine#'
      local mod = vim.bo[buf].modified and ' ●' or ''
      local label = buf_label(buf)

      s = s .. hl .. ' %' .. buf .. 'T ' .. label .. mod .. ' '
    end
  end

  return s .. '%#TabLineFill#%T'
end

vim.o.tabline = '%!v:lua.MyTabline()'

vim.api.nvim_create_autocmd(
  { 'RecordingEnter', 'RecordingLeave', 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI' },
  {
    callback = function()
      vim.cmd('redrawstatus')
    end,
  }
)
