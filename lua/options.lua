--    ╭────────────────────────────╮
--    │        options.lua         │
--    ╰────────────────────────────╯

-- global options settings
-- split from settings on advice from Gemini for clarity and maintenance

local M = {}

function M.setup()
  -- stylua: ignore
  local options = {
    -- DISPLAY AND WRAP
    autoindent     = true,
    cmdwinheight   = 12,
    conceallevel   = 0,
    copyindent     = true,
    expandtab      = true,
    guicursor      = 'n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250',
    laststatus     = 3,
    linebreak      = true,
    listchars      = { eol = '↲', tab = '▸ ', trail = '·' },
    number         = false,
    relativenumber = false,
    scrolloff      = 1,
    shiftround     = true,
    shiftwidth     = 2,
    showmode       = false,
    showtabline    = 2,
    smartindent    = true,
    softtabstop    = 2,
    splitbelow     = true,
    splitright     = true,
    tabstop        = 2,
    termguicolors  = true,
    timeout        = true,
    timeoutlen     = 1000,
    title          = true,
    virtualedit    = 'block',
    whichwrap      = '<,>,h,l',
    wrap           = true,

    -- SEARCH
    ignorecase     = true,
    incsearch      = true,
    smartcase      = true,

    -- SYSTEM
    backup         = true,
    backupcopy     = 'yes',
    confirm        = true,
    clipboard      = 'unnamedplus',
    swapfile       = true,
    undofile       = true,
    spell          = false,

    -- neovim 0.12 / blink.cmp optimizations
    autocomplete   = false,
    wildmenu       = false,
    wildmode       = 'longest:full,full',
    cmdheight      = 0,

    wildchar       = 0, -- Disable the trigger key for native wildmenu
    wildoptions    = '', -- Clear native wildmenu UI options

  }

  -- Apply basic options
  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  -- Set up path and directories
  vim.opt.backupdir = vim.fn.stdpath('data') .. '/backup//'
  vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'
  vim.opt.path:append('**')

-- disable providers not needed (speed optimization)
  -- stylua: ignore
  if vim.g.enable_providers ~= true then
    vim.g.loaded_node_provider    =  0
    vim.g.loaded_perl_provider    =  0
    vim.g.loaded_python3_provider =  0
    vim.g.loaded_ruby_provider    =  0
  end

  -- disable built-in plugins not needed
  local disabled_builtins = {
    '2html_plugin',
    'getscript',
    'getscriptPlugin',
    'gzip',
    'logipat',
    'matchit',
    'matchparen',
    'netrwPlugin',
    'netrw',
    'nvim_dir_plugin',
    'nvim_net_plugin',
    'nvim_zip_plugin',
    'rrhelper',
    'tar',
    'tarPlugin',
    'tohtml',
    'tutor',
    'vimball',
    'undotree',
    'zip',
    'zipPlugin',
  }

  for _, plugin in ipairs(disabled_builtins) do
    vim.g['loaded_' .. plugin] = 1
  end
end

-- ──────────────────────────────────────────────────────────────────────
-- Custom Fold and Status Column Configuration
-- ──────────────────────────────────────────────────────────────────────

local function clean_leader(s)
  s = (s or ''):gsub('^%s*', '')
  s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
  return s
end

_G.MyFoldText = function()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local count = fe - fs + 1
  local first_line = vim.fn.getline(fs)
  local ind_cols = math.min(vim.fn.indent(fs), 32)
  local prefix = string.rep(' ', ind_cols)

  local content = clean_leader(first_line)
  local winw = vim.api.nvim_win_get_width(0)
  local avail = math.max(20, winw - 15 - ind_cols)

  if vim.fn.strdisplaywidth(content) > avail then
    content = vim.fn.strcharpart(content, 0, avail) .. '…'
  end

  return string.format(' >>>   %s%s  ⋯  [%d]   <<<', prefix, content, count)
end

-- Core Fold Options
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldtext = 'v:lua.MyFoldText()'

-- fillchars + statuscolumn logic
-- this forces the fold column to be empty unless it's an icon
vim.opt.fillchars = {
  eob = ' ',
  foldopen = '▼',
  foldclose = '▶',
  fold = ' ',
  foldsep = ' ',
}

function _G.MyStatusColumn()
  local fcs = vim.opt.fillchars:get()
  local lnum = vim.v.lnum

  local mark_char = ''
  -- Fetch all local marks at once instead of making 26 API calls per screen line.
  for _, mark in ipairs(vim.fn.getmarklist(vim.api.nvim_get_current_buf())) do
    local char = mark.mark:match("^'([a-z])$")
    if char and mark.pos[2] == lnum then
      mark_char = char
      break
    end
  end

  local foldlevel = vim.fn.foldlevel(lnum)
  local foldclosed = vim.fn.foldclosed(lnum)
  local fold_str = '  '
  if foldclosed ~= -1 and foldclosed == lnum then
    fold_str = fcs.foldclose .. ' '
  elseif foldlevel > 0 and foldlevel > vim.fn.foldlevel(lnum - 1) then
    fold_str = fcs.foldopen .. ' '
  end

  -- combine: mark (if exists) + fold + line number
  -- if there's a mark, we show it; otherwise, we show a space
  local mark_display = mark_char ~= '' and mark_char or ' '

  return mark_display .. ' ' .. fold_str .. '%=%l '
end

-- apply the statuscolumn
-- note: putting %s at the beginning often helps visibility in minimalist setups
vim.opt.statuscolumn = '%s%{%v:lua.MyStatusColumn()%}'

-- Disable the native foldcolumn because we are drawing it ourselves now
vim.opt.foldcolumn = '0'

return M
