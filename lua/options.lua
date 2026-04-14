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
    hlsearch       = false,

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

  -- Apply basic options
  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  -- make sure coding is right
  vim.scriptencoding = 'utf-8'
  vim.opt.encoding = 'utf-8'
  vim.opt.fileencoding = 'utf-8'

  -- Path and Directories
  vim.opt.backupdir = vim.fn.stdpath('data') .. '/backup//'
  vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'
  vim.opt.path = '+= **'
  -- Specific to your Linux environment
  vim.opt.runtimepath:append('/home/bert/.local/share/nvim/site')

  -- Shortmess and Fillchars
  vim.opt.fillchars:append({ eob = ' ' })
  vim.opt.shortmess:append('IF')

  -- Provider disabling (Speed optimization)
  if vim.g.enable_providers ~= true then
    vim.g.loaded_node_provider = 0
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_python3_provider = 0
    vim.g.loaded_ruby_provider = 0
  end

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
    'nwtrw',
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

return M
