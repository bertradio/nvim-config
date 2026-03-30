-- init.lua
-- changed from lazy to vim.pack 3-30-26

-- PATH setup (all PATH mutations live here)
Myfn = require('my_fns')

local data = vim.fn.stdpath('data')

-- set mason path
if vim.fn.has('win32') == 1 then
  Myfn.add_to_vim_path(data .. '\\mason\\bin')
else
  Myfn.add_to_vim_path(data .. '/mason/bin')
end

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
  -- vim.g.neovide.size = '1280x800'
  -- vim.g.neovide_remember_window_size = true
  -- vim.g.neovide_fullscreen = true
end

-- set leader to a space instead of \
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- initialization files
require('augroups')
require('keymaps')
require('settings')

-- plugins
-- Load catppuccin first (colorscheme must be first)
require('plugins.catppuccin')
-- Then load everything else in lua/plugins/ automatically
for _, file in
  ipairs(vim.fn.globpath(vim.fn.stdpath('config') .. '/lua/plugins', '*.lua', false, true))
do
  local name = vim.fn.fnamemodify(file, ':t:r') -- strip path and .lua extension
  if name ~= 'catppuccin' then -- skip since already loaded
    require('plugins.' .. name)
  end
end

-- set directories and shortcuts based on platform
if Myfn.is_windows() then
  require('bookmarks_win')
else
  require('bookmarks_linux')
end

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
