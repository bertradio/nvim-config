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
    laststatus     = 3,
    tabstop        = 2,
    termguicolors  = true,
    title          = true,
    timeout        = true,
    timeoutlen     = 800,
    virtualedit    = 'block',
    whichwrap      = '<,>,h,l',
    wrap           = true,
    guicursor      = 'n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250',

    -- SEARCH
    ignorecase     = true,
    incsearch      = true,
    smartcase      = true,
    hlsearch       = true,

    -- SYSTEM
    backup         = true,
    backupcopy     = 'yes',
    confirm        = true,
    clipboard      = 'unnamedplus',
    history        = 500,
    swapfile       = true,
    undofile       = true,
    undolevels     = 500,
    spell          = false,

    -- NEVOM 0.12 / BLINK.CMP OPTIMIZATIONS
    autocomplete   = false,
    wildmenu       = false,
    wildmode       = 'longest:full,full',
    cmdheight      = 0, -- Set for Noice
  }

  vim.opt.wildchar = 0 -- Disable the trigger key for native wildmenu
  vim.opt.wildoptions = '' -- Clear native wildmenu UI options

  -- Apply basic options
  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  require('vim._core.ui2').enable({})

  -- make sure coding is right
  vim.scriptencoding = 'utf-8'
  vim.opt.encoding = 'utf-8'
  vim.opt.fileencoding = 'utf-8'

  -- Path and Directories
  vim.opt.backupdir = vim.fn.stdpath('data') .. '/backup//'
  vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'
  vim.opt.path = '+= **'
  -- Specific to Linux environment
  vim.opt.runtimepath:append('/home/bert/.local/share/nvim/site')

  -- Shortmess and Fillchars
  vim.opt.fillchars:append({ eob = ' ' })
  vim.opt.shortmess:append('IF')

-- Provider disabling (Speed optimization)
  -- stylua: ignore 
  if vim.g.enable_providers ~= true then
    vim.g.loaded_node_provider    =  0
    vim.g.loaded_perl_provider    =  0
    vim.g.loaded_python3_provider =  0
    vim.g.loaded_ruby_provider    =  0
  end

  -- activate built-in for nvim 0.12
  vim.cmd('packadd nvim.undotree')
  vim.keymap.set('n', '<leader>u', require('undotree').open, { desc = 'Undotree' })

  -- Disable Built-in Plugins
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
    'rrhelper',
    'tar',
    'tarPlugin',
    'tohtml',
    'tutor',
    'vimball',
    'zip',
    'zipPlugin',
  }
  for _, plugin in ipairs(disabled_builtins) do
    vim.g['loaded_' .. plugin] = 1
  end

  local signs = { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' }
  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Custom Highlights
  vim.api.nvim_set_hl(0, 'Folded', { fg = '#cccccc', bg = '#154360', italic = true })
end

-- ──────────────────────────────────────────────────────────────────────
-- Custom Fold and Status Column Configuration (Snacks-free)
-- ──────────────────────────────────────────────────────────────────────

-- 1. Helper function
local function clean_leader(s)
  s = (s or ''):gsub('^%s*', '')
  s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
  return s
end

-- 2. Global Fold Text
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

-- 3. Core Fold Options
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldtext = 'v:lua.MyFoldText()'

-- 4. THE NUMBER KILLER: fillchars + statuscolumn logic
-- This forces the fold column to be empty unless it's an icon
vim.opt.fillchars = {
  foldopen = '▼',
  foldclose = '▶',
  fold = ' ',
  foldsep = ' ',
}

-- We use a Lua expression in the statuscolumn.
-- It checks if the current line is the start of a fold.
-- If not, it returns a space. If it is, it returns the fold icon.
-- 4. Optimized StatusColumn Function
function _G.MyStatusColumn()
  local fcs = vim.opt.fillchars:get()
  local lnum = vim.v.lnum

  -- 1. Check for a mark on this line
  local mark_char = ''
  -- Look for lowercase marks (a-z)
  for i = 97, 122 do
    local char = string.char(i)
    local mark = vim.api.nvim_buf_get_mark(0, char)
    if mark[1] == lnum then
      mark_char = char
      break
    end
  end

  -- 2. Fold Logic
  local foldlevel = vim.fn.foldlevel(lnum)
  local foldclosed = vim.fn.foldclosed(lnum)
  local fold_str = '  '
  if foldclosed ~= -1 and foldclosed == lnum then
    fold_str = fcs.foldclose .. ' '
  elseif foldlevel > 0 and foldlevel > vim.fn.foldlevel(lnum - 1) then
    fold_str = fcs.foldopen .. ' '
  end

  -- 3. Combine: Mark (if exists) + Fold + Line Number
  -- If there's a mark, we show it; otherwise, we show a space
  local mark_display = mark_char ~= '' and mark_char or ' '

  return mark_display .. ' ' .. fold_str .. '%=%l '
end

-- Apply the statuscolumn
-- Note: Putting %s at the beginning often helps visibility in minimalist setups
vim.opt.statuscolumn = '%s%{%v:lua.MyStatusColumn()%}'

-- Disable the native foldcolumn because we are drawing it ourselves now
vim.opt.foldcolumn = '0'

-- Disable native wildmenu so it doesn't fight with blink
vim.opt.wildchar = 0
vim.opt.wildoptions = ''

return M
