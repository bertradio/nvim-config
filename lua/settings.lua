-- settings.lua
-- changed 7/6/25 for win and Linux

-------------------------------------------------
-- >>> BASIC SETTINGS
-------------------------------------------------

-- stylua: ignore

-- dictionary to hold all options
local options = {

	-- DISPLAY AND WRAP --

	autoindent     = true, -- autoindent on
	cmdwinheight   = 12, -- set size of command window
	conceallevel   = 0,
	copyindent     = true, -- copy the previous indentation on autoindenting
	expandtab      = true, -- expand tabs to spaces by default
	linebreak      = true, -- don't break lines in the middle of words
	listchars      = { eol = '↲', tab = '▸ ', trail = '·' }, -- set visuals for list mode (:set list)
	number         = false, -- show line numbers
	relativenumber = false, -- show relative line  numbers
	scrolloff      = 1, -- keep 1 line off the edges of the screen when scrolling
	shiftround     = true, -- use multiple of shiftwidth when indenting with '<' and '>'
	shiftwidth     = 2, -- amount to shift when hitting > or <
	shortmess      = 'IF', -- don't display startup screen when nvim starts or file info on load
	showmode       = false, -- always show what mode we're currently in on status line
	smartindent    = true,
	softtabstop    = 2,
	splitbelow     = true,     -- Open splits below current window (default  = above)
	splitright     = true,     -- Open splits below current window (default  = above)
	laststatus     = 3,        -- global statusline
	tabstop        = 2,        -- tab and other indent settings
	termguicolors  = true,     -- use colors from terminal emulator (e.g. Kitty)
	title          = true,     -- put current filename in window header
	timeout        = true,
	timeoutlen     = 800,      -- time between 2 character commands
	virtualedit    = 'block',  -- In block mode, permit going places with no character
	whichwrap      = '<,>,h,l', -- make keys move from end of line to next char
	wrap           = true,     -- word wrap on (default = true)

	-- set cursor see :h guicursor
	-- block for command, vertical line for insert - blink
	-- guicursor      = 'n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20',
  -- Add the blink settings to the end of your string - from Gemini
  guicursor = 'n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250',

  -- SEARCH --

	ignorecase     = true, -- ignore case on searches
	incsearch      = true, -- show search results as type
	smartcase      = true, -- but don't ignore case if any capital letter used

	-- SYSTEM --

	-- autochdir      = true, -- automatically change cwd to buffer?
	backup         = true, -- turn backup on and specify directory
	backupcopy     = 'yes',
	backupdir      = vim.fn.stdpath('data') .. '/backup//',
	confirm        = true,         -- ask for confirmation if try to exit with unsaved buffer
	clipboard      = 'unnamedplus', -- use system clipboard - for wl-clipboard
	history        = 500,          -- keep 500 lines of history
	swapfile       = true,         -- swap files, if on, located in /home/bert/.local/state/nvim/swap
	undofile       = true,
	undolevels     = 500,
	undodir        = vim.fn.stdpath('data') .. '/undo',

	-- save global variables,
	-- a maximum of 100 files marked
	-- a maximum of 50 lines per register,
	-- and a maximum of 100kb for each item
	shada          = "!,'100,<50,s100",
} -- end options dictionary

-- stylua: ignore end:

-- loop to use vim.opt to execute settings from options dictionary defined above
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- remove ~ at end of buffers
vim.opt.fillchars:append({ eob = ' ' })

-- Don't clobber default shortmess; just add the flags we want.
vim.opt.shortmess:append('I') -- no intro
vim.opt.shortmess:append('F')

-- Ensure backup/undo directories exist (prevents silent failures)
local data_dir = vim.fn.stdpath('data')
vim.fn.mkdir(data_dir .. '/undo', 'p')
vim.fn.mkdir(data_dir .. '/backup', 'p')
-- should work for linux and win
local backupdir = vim.fn.stdpath('data') .. '/backup/'
vim.opt.backup = true
vim.opt.backupdir = backupdir

-- Enable spell checking globally (optional)
vim.opt.spell = false

--------------------------------------------------
-- >>> OTHER SETUP
-------------------------------------------------

--[[ setup for internal file search plugin access with :field
   [ if followed by wildcard expression, use tab to expand into menu ]]
vim.opt.path = '+= **' -- set path for recursive search of directories
-- vim.opt.wildmenu = true      -- use menu for wildcards
vim.cmd('filetype plugin on') -- activate plugin

-- icons for diagnostics
vim.diagnostic.config({
  signs = {
    [vim.diagnostic.severity.ERROR] = { text = '🤬' },
    [vim.diagnostic.severity.WARN] = { text = '🖐️' },
    [vim.diagnostic.severity.HINT] = { text = '☝️' },
    [vim.diagnostic.severity.INFO] = { text = '🤓' },
  },
})

-------------------------
-- Diff with last save --
-------------------------

vim.api.nvim_create_user_command('DiffWithSaved', function()
  -- Get current buffer info
  local cur_buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(cur_buf)

  -- Check if file exists on disk
  if filename == '' or not vim.fn.filereadable(filename) then
    vim.notify('File not saved on disk!', vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.filetype
  local cur_lines = vim.api.nvim_buf_get_lines(cur_buf, 0, -1, false)
  local saved_lines = vim.fn.readfile(filename)

  -- Create new tab
  vim.cmd('tabnew')

  -- Function to create and setup a scratch buffer
  local function create_scratch_buffer(lines, title)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', ft, { buf = buf })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_set_option_value('winbar', title, { scope = 'local' })
    return buf
  end

  -- Create first scratch buffer with current content
  local buf1 = create_scratch_buffer(cur_lines, 'Unsaved changes')

  -- Create vertical split
  vim.cmd('vsplit')

  -- Create second scratch buffer with saved content
  local buf2 = create_scratch_buffer(saved_lines, 'File on disk')

  -- Enable diff mode for both windows
  vim.cmd('windo diffthis')

  -- Add keymapping to close diff view
  local function close_diff()
    vim.cmd('tabclose')
  end

  vim.keymap.set('n', 'q', close_diff, { buffer = buf1, silent = true })
  vim.keymap.set('n', 'q', close_diff, { buffer = buf2, silent = true })
end, {})

vim.keymap.set(
  'n',
  '<leader>ds',
  '<cmd>DiffWithSaved<cr>',
  { desc = 'Diff with last save' },
  { remap = false, silent = true }
)

-- command to sort tables
-- works in visual mode Sort followed by the column number
vim.api.nvim_create_user_command('Sort', function(opts)
  if not tonumber(opts.args) then
    print('Error: Argument must be a number')
    return
  end
  local bang = opts.bang and '!' or ''
  local range = opts.range == 0 and '' or ('%d,%d'):format(opts.line1, opts.line2)
  -- use next line for sort case insensitive
  -- local pattern = string.format('%ssort i%s /^\\([^|]*|\\)\\{%s\\}/', range, bang, opts.args)
  local pattern = string.format('%ssort%s /^\\([^|]*|\\)\\{%s\\}/', range, bang, opts.args)
  vim.cmd(pattern)
end, { nargs = 1, bang = true, range = true })

-- Disable built-in plugins not needed- from Gemini
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
  'tarPl`ugin',
  'tohtml',
  'tutor',
  'vimball',
  'zip',
  'zipPlugin',
}

for _, plugin in ipairs(disabled_builtins) do
  vim.g['loaded_' .. plugin] = 1
end

-------------------- From init.lua ------------------------

-- user / app binaries
if vim.fn.has('win32') == 1 then
  for _, p in ipairs({
    [[C:\Program Files\Yazi]],
    [[C:\Program Files (x86)\Yazi]],
  }) do
    if vim.fn.isdirectory(p) == 1 then
      Myfn.add_to_vim_path(p)
      break
    end
  end
end

-- from Gemini to makes sure everything is compiled
if vim.loader then
  vim.loader.enable()
end

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1

-- Disable the new 0.12 native autocomplete feature
vim.opt.autocomplete = false
-- Disable the horizontal wildmenu so it doesn't conflict with blink's menu
vim.opt.wildmenu = false
-- Change how the command line completes to avoid the native popup
vim.opt.wildmode = 'longest:full,full'

-- make sure nvim can find all parsers
vim.opt.runtimepath:append('/home/bert/.local/share/nvim/site')

-- Enable floating cmdline/popupmenu (required for Noice cmdline popup)
vim.opt.cmdheight = 0

-- Provider loading can add startup cost and noisy errors if you don't use them.
-- Set `vim.g.enable_providers = true` before startup to keep them enabled.
if vim.g.enable_providers ~= true then
  vim.g.loaded_node_provider = 0 -- don't load Node.js provider
  vim.g.loaded_perl_provider = 0 -- don't load Perl provider
  vim.g.loaded_python3_provider = 0 -- don't load Python provider
  vim.g.loaded_ruby_provider = 0 -- don't load Ruby provider
end

-- set config if running neovide
if vim.g.neovide then
  if Myfn.is_windows() then
    vim.o.guifont = 'JetBrainsMono NFP:h15'
    -- Don’t persist window size (prevents writing back a maximized state)
    vim.g.neovide_fullscreen = false
    vim.g.neovide_remember_window_size = true
    -- vim.g.neovide_scale_factor = 1.4
    vim.schedule(function()
      vim.o.columns = 125
      vim.o.lines = 35
    end)
  else
    vim.o.guifont = 'JetBrainsMono NFP:h12'
  end
end

-- set leader to a space instead of \
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- setting these after everything else
vim.opt.hlsearch = false

-- set highlights for fold lines
vim.api.nvim_set_hl(0, 'Folded', { fg = '#cccccc', bg = '#154360', italic = true })

-- set abbrev for page break for md to pdf via pandoc
vim.cmd([[
  iabbrev pbk <div style="page-break-after:always"></div>
]])

-- put this somewhere after markview is loaded
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('MarkviewSnacksFix', { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == 'markdown' then
      pcall(vim.cmd, 'Markview enable')
    end
  end,
})

-- set directories and shortcuts based on platform
if Myfn.is_windows() then
  require('bookmarks_win')
else
  require('bookmarks_linux')
end
