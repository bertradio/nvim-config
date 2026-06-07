-- mini-status-tab.lua

-- Created: 06/06/26

-- replacement for lualine from Gemini

--    ╭────────────────────────────╮
--    │    mini-status-tab.lua     │
--    ╰────────────────────────────╯

-- vim.pack.add({
--   Gh('nvim-tree/nvim-web-devicons'),
--   Gh('echasnovski/mini.statusline'),
--   Gh('echasnovski/mini.tabline'),
-- })

local mini_statusline = require('mini.statusline')
local mini_tabline = require('mini.tabline')

--  ━━━━━ display functions for use on status line ━━━━━

--  ───── number of words in buffer ─────
local function getWords()
  local wc = vim.fn.wordcount()
  if wc['visual_words'] then
    return wc['visual_words'] .. ' Words selected'
  else
    return wc['words'] .. ' Words'
  end
end

--  ───── whether spellcheck is on ─────
local function spellOn()
  return vim.wo.spell and 's+' or ''
end

--  ───── display while macro is being recorded ─────
local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == '' then
    return ''
  else
    return 'Recording @' .. recording_register
  end
end

-- Refresh logic for macro recording via redrawing statusline
vim.schedule(function()
  local grp = vim.api.nvim_create_augroup('MiniStatuslineRecording', { clear = true })
  vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
    group = grp,
    callback = function()
      vim.cmd('redrawstatus')
    end,
  })
end)

--  ───── Oil buffer tab title formatter ─────
local OIL_TAB_SHOW_FULL_PATH = true

local function dir_from_oil_bufname(bufnr)
  local raw = vim.api.nvim_buf_get_name(bufnr) or ''
  raw = raw:gsub('^oil://', ''):gsub('^oil%-trash://', '')
  raw = raw:gsub('^/*', '')
  return raw
end

local function oil_tab_fmt(bufnr)
  local default_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].filetype ~= 'oil' then
    return default_name == '' and '[No Name]' or default_name
  end

  local dir
  local ok_oil, oil = pcall(require, 'oil')
  if ok_oil and type(oil.get_current_dir) == 'function' then
    local ok_dir, got = pcall(oil.get_current_dir, bufnr)
    dir = ok_dir and got or oil.get_current_dir()
  end

  if not dir or dir == '' then
    dir = dir_from_oil_bufname(bufnr)
  end

  if not OIL_TAB_SHOW_FULL_PATH then
    return 'Oil'
  else
    return 'Oil: ' .. vim.fn.fnamemodify(dir, ':~')
  end
end

--  ━━━━━━ Setup Components ━━━━━━

-- Define a custom highlight group for your orange Macro Indicator
vim.api.nvim_set_hl(0, 'MiniStatuslineMacro', { fg = '#FFA500', bg = nil })

mini_statusline.setup({
  content = {
    active = function()
      -- Mode & Branch (Sections A & B)
      local mode, mode_hl = mini_statusline.section_mode({ truncated_width = 120 })
      local branch = (Myfn and Myfn.short_cwd)
        or mini_statusline.section_git({ truncated_width = 75 })

      -- Components for Section X
      local macro = show_macro_recording()
      local spell = spellOn()

      -- Native searchcount evaluation to completely avoid custom loops
      local search = ''
      if vim.v.hlsearch == 1 then
        local s_count = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
        if s_count.total and s_count.total > 0 then
          search = string.format('[%d/%d]', s_count.current, s_count.total)
        end
      end

      -- Component for Section Z
      local words = getWords()

      -- Draw the combined native string
      return mini_statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { branch } },
        '%=', -- Separation point (Align right)
        { hl = 'MiniStatuslineMacro', strings = { macro } },
        { hl = 'MiniStatuslineFileinfo', strings = { spell, search } },
        { hl = mode_hl, strings = { words } },
      })
    end,
  },
  set_vim_settings = false, -- keeps your existing globalstatus settings intact
})

mini_tabline.setup({
  show_icons = true,
  format = function(bufnr, label)
    -- Run our unique Oil string parser
    local formatted_name = oil_tab_fmt(bufnr)

    -- Replicate show_modified_status / modified = ' ●'
    if vim.bo[bufnr].modified then
      return formatted_name .. ' ●'
    end
    return formatted_name
  end,
})
