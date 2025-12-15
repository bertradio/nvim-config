-- treesitter.lua re-write by Gemini
-- for new re-write by author

return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		config = function()
			local api = require('nvim-treesitter')

			-- 1. List of parsers to install
			local ensure_installed = {
				'awk', 'bash', 'c', 'csv', 'json', 'lua', 'markdown',
				'markdown_inline', 'python', 'query', 'regex', 'toml',
				'vim', 'vimdoc', 'powershell', 'diff',
			}

			-- 2. "Safe Install": Only try to install missing parsers
			-- Attempting to install an already-loaded parser can crash Neovim
			local to_install = {}
			for _, lang in ipairs(ensure_installed) do
				-- Check if the parser file exists in Neovim's runtime path
				local found = vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false)
				if #found == 0 then
					table.insert(to_install, lang)
				end
			end

			-- 3. Install missing parsers
			if #to_install > 0 then
				pcall(api.install, to_install)
			end

			-- 4. Configure Huge File Check
			local function is_too_big(buf)
				local max = 200 * 1024 -- 200 KB
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max then
					return true
				end
				return false
			end

			-- 5. Enable Features (Highlighting, Indent) via Autocommands
			vim.api.nvim_create_autocmd('FileType', {
				group = vim.api.nvim_create_augroup('nvim-treesitter', { clear = true }),
				callback = function(args)
					if is_too_big(args.buf) then return end

					-- Enable Highlighting
					pcall(vim.treesitter.start, args.buf)

					-- Enable Indentation
					if vim.bo[args.buf].filetype ~= 'markdown' then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- 6. Enable Folding
			vim.o.foldmethod = 'expr'
			vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		end,
	},
}
