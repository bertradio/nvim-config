-- init.lua
-- changed from lazy to vim.pack 3-30-26

-- -- set mason path
-- if vim.fn.has('win32') == 1 then
--   Myfn.add_to_vim_path(nvimdata .. '\\mason\\bin')
-- else
--   -- Myfn.add_to_vim_path(nvimdata .. '/mason/bin')
--   -- Only add Mason to PATH if it's missing to avoid duplicates
--   local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
--   if not string.find(vim.env.PATH, mason_bin, 1, true) then
--     vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
--   end
-- end

-- simplify code
local gh = function(x)
  return 'https://github.com/' .. x
end

-- recommended way - load all adds at once
vim.pack.add({
  { src = gh('catppuccin/nvim'), name = 'catppuccin' },
  { src = gh('HiPhish/rainbow-delimiters.nvim') },
  { src = gh('MeanderingProgrammer/markdown.nvim') },
  { src = gh('MunifTanjim/nui.nvim') },
  { src = gh('code-biscuits/nvim-biscuits') },
  { src = gh('dkarter/bullets.vim') },
  { src = gh('folke/flash.nvim') },
  { src = gh('folke/lazydev.nvim'), data = { ft = 'lua' } },
  { src = gh('folke/noice.nvim') },
  { src = gh('folke/which-key.nvim') },
  { src = gh('ibhagwan/fzf-lua') },
  { src = gh('kdheepak/lazygit.nvim') },
  { src = gh('mikavilpas/yazi.nvim') },
  { src = gh('nemanjamalesija/smart-paste.nvim') },
  { src = gh('neovim/nvim-lspconfig') },
  { src = gh('nvim-lua/plenary.nvim') },
  { src = gh('nvim-lualine/lualine.nvim') },
  { src = gh('nvim-mini/mini.nvim') },
  { src = gh('nvim-tree/nvim-web-devicons') },
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  { src = gh('rcarriga/nvim-notify') },
  { src = gh('ribru17/blink-cmp-spell') },
  { src = gh('saghen/blink.cmp'), version = 'v1.10.2' },
  { src = gh('saghen/blink.indent') },
  { src = gh('stevearc/conform.nvim') },
  { src = gh('stevearc/oil.nvim') },
  { src = gh('williamboman/mason-lspconfig.nvim') },
  { src = gh('williamboman/mason.nvim') },
  { src = gh('windwp/nvim-autopairs') },
})

Myfn = require('my_fns')

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

-- initialization files
require('augroups')
require('keymaps')
require('settings')

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
