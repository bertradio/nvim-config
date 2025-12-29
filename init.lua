-- init.lua

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.env.TERM = 'xterm-256color'

-- Enable floating cmdline/popupmenu (required for Noice cmdline popup)
vim.opt.cmdheight = 0

-- make sure lazy.vim is downloaded and load
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out =
			vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out,                            'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

vim.g['loaded_node_provider'] = 0    -- remove attempt to load Node.js
vim.g['loaded_perl_provider'] = 0    -- remove attempt to load Perl
vim.g['loaded_python3_provider'] = 0 -- remove attempt to load Python
vim.g['loaded_ruby_provider'] = 0    -- remove attempt to load Ruby

Myfn = require('my_fns')

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
		vim.o.guifont = 'JetBrainsMono NFP:h16'
	end
	-- vim.g.neovide.size = '1280x800'
	-- vim.g.neovide_remember_window_size = true
	-- vim.g.neovide_fullscreen = true
end

-- set leader to a space instead of \
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- code from Gemini to speed up loading
require("lazy").setup({
	spec = { { import = "plugins" } },
	cache = { { enabled = true } }, -- make sure everything compiled
	defaults = {
		lazy = true,                 -- This makes plugins lazy-loaded by default unless specified otherwise
	},
	performance = {
		rtp = {
			-- Disable unused builtin vim plugins to save startup time
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"netrwPlugin", -- Only if you use a different file explorer like nvim-tree/oil
			},
		},
	},
})
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


-- Ensure nvim can find the yazi executable - from ChatGPT
-- adds director to nvim path
if Myfn.is_windows() then
	Myfn.add_to_vim_path('C:\\Program Files (x96)\\Yazi')
else
	Myfn.add_to_vim_path('~/.local/bin')
end

-- put this somewhere after markview is loaded
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("MarkviewSnacksFix", { clear = true }),
	callback = function(ev)
		if vim.bo[ev.buf].filetype == "markdown" then
			pcall(vim.cmd, "Markview enable")
		end
	end,
})
