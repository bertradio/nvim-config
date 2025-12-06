-- statuscolumn.lua
-- code from Chat GPT
-- removed snacks indent because it overwrote part of the fold line
-- Created: 10/22/25

-- Code from ChatGPT to format line that displays when fold closes
-- Displays beginning of line and number of lines in fold
-- Also aligns with prior indent of line
local function _clean_leader(s)
  s = (s or ''):gsub('^%s*', '')
  s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
  return s
end

function _G.MyFoldText()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local count = fe - fs + 1

  -- Original first line & its *visual* indent (in columns)
  local first = vim.fn.getline(fs)
  local ind_cols = vim.fn.indent(fs) -- visual spaces, respects tabs

  -- Bound the indent so deep blocks don't push off screen
  local max_indent_cols = 32 -- tweak to taste
  if ind_cols > max_indent_cols then
    ind_cols = max_indent_cols
  end
  local prefix = string.rep(' ', ind_cols) -- normalize to spaces for stability

  -- Remove *all* leading whitespace using a capture (works w/ tabs & spaces)
  local content = first:match('^%s*(.*)$') or first
  content = _clean_leader(content)

  -- Fit preview to window width minus indent & padding
  local winw = vim.api.nvim_win_get_width(0)
  local padding = 10 -- room for " ⋯ [n]"
  local avail = math.max(20, winw - padding - ind_cols)

  -- Clip by *display width* (handles wide chars)
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

return {
  'snacks.nvim',
  opts = {
    statuscolumn = {
      enabled = true,
      segments = {
        { text = { '%s' }, click = 'v:lua.ScSa' }, -- signs
        { text = { '%C' } }, -- native fold column (closed/open markers)
        {
          text = { -- numbers (respects relativenumber)
            function()
              if vim.v.virtnum ~= 0 then
                return ''
              end
              if vim.wo.relativenumber then
                local rel = math.abs(vim.fn.line('.') - vim.v.lnum)
                return (rel == 0 and vim.v.lnum or rel) .. ' '
              end
              return string.format('%d ', vim.v.lnum)
            end,
          },
          click = 'v:lua.ScNa',
        },
      },
    },
  },

  -- initialize folding settings
  init = function()
    -- Folding
    vim.opt.foldenable = true
    -- for Treesitter folds
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldlevel = 99
    -- Use our preview text for closed folds
    vim.opt.foldtext = 'v:lua.MyFoldText()'

    -- Let %C actually render: give foldcolumn a width (1-2 is plenty)
    vim.opt.foldcolumn = '1'

    vim.opt.fillchars:append({
      foldopen = '▼',
      foldclose = '▶',
      fold = '·',
      foldsep = ' ',
    })
  end,
}
