-- init.lua for Snacks

-- Optional Windows shell tweak
if Myfn and Myfn.is_windows and Myfn.is_windows() then
	vim.o.shell = 'pwsh.exe'
	vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
	vim.o.shellquote = ''
	vim.o.shellxquote = ''
end

return {
	'folke/snacks.nvim',
	lazy = false,
	priority = 1000,
	import = 'plugins.snacks',
	opts = {
		bigfile = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		quickfile = { enabled = true },
		rename = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },

		dashboard = { enabled = false },
		image = { enabled = false },
		indent = { enabled = false },
		notifier = { enabled = false },
		terminal = { enabled = false },
	},
}
