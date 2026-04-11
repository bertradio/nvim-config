-- snacks-statuscolumn.lua
-- changed from lazy to vim.pack 3-30-26

local function _clean_leader(s)
  s = (s or ''):gsub('^%s*', '')
  s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
  return s
end

function _G.MyFoldText()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local count = fe - fs + 1

  local first = vim.fn.getline(fs)
  local ind_cols = vim.fn.indent(fs)

  local max_indent_cols = 32
  if ind_cols > max_indent_cols then
    ind_cols = max_indent_cols
  end

  local prefix = string.rep(' ', ind_cols)
  local content = first:match('^%s*(.*)$') or first
  content = _clean_leader(content)

  local winw = vim.api.nvim_win_get_width(0)
  local padding = 10
  local avail = math.max(20, winw - padding - ind_cols)

  local function clip_display(s, w)
    if vim.fn.strdisplaywidth(s) <= w then
      return s
    end
    local out, used = {}, 0
    for _, ch in utf8.codes(s) do
      local c = utf8.char(ch)
      local cw = vim.fn.strdisplaywidth(c)
      if used + cw > w then
        break
      end
      table.insert(out, c)
      used = used + cw
    end
    return table.concat(out) .. '…'
  end

  local preview = clip_display(content, avail)
  return string.format('%s%s  ⋯  [%d]', prefix, preview, count)
end

vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldtext = 'v:lua.MyFoldText()'
vim.opt.foldcolumn = 'auto:1'

vim.opt.fillchars:append({
  foldopen = '▼',
  foldclose = '▶',
  -- fold = '·',
  fold = ' ',
  foldsep = ' ',
})
