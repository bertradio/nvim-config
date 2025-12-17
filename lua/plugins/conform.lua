-- conform.lua
-- Created: 2023-12-17
-- Sync-safe across Linux & Windows (Syncthing). No Myfn dependency.

return {
	'stevearc/conform.nvim',
	event  = { 'BufReadPre', 'BufNewFile' },
	cmd    = { 'ConformInfo' },

	config = function()
		local conform = require('conform')

		---------------------------------------------------------------------------
		-- Cross-OS executable chooser (Linux vs Windows mason shims)
		---------------------------------------------------------------------------
		local function choose_cmd(candidates)
			for _, cmd in ipairs(candidates) do
				if vim.fn.executable(cmd) == 1 then
					return cmd
				end
			end
			-- Fall back to the first; Conform will surface a clear error if missing
			return candidates[1]
		end

		-- Detect platform once
		local is_windows = vim.loop.os_uname().version:match('Windows')
				or (vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1)

		-- Prefer prettierd if present (fast daemon). Otherwise fall back to prettier.
		local prettier_cmd = choose_cmd(
			is_windows and { 'prettierd.cmd', 'prettier.cmd', 'prettierd', 'prettier' }
			or { 'prettierd', 'prettier' }
		)

		local stylua_cmd = choose_cmd(is_windows and { 'stylua.exe', 'stylua' } or { 'stylua' })

		local shfmt_cmd = choose_cmd(is_windows and { 'shfmt.exe', 'shfmt' } or { 'shfmt' })

		---------------------------------------------------------------------------
		-- Setup: formatters per filetype + format-on-save
		---------------------------------------------------------------------------
		conform.setup({

			-- Format on save; let LSP handle anything without an external formatter
			format_on_save = {
				lsp_format = 'fallback',
				timeout_ms = 1500, -- roomy enough for PSES and friends
			},

		})

		---------------------------------------------------------------------------
		-- Formatter command overrides (cross-OS friendly) + options
		---------------------------------------------------------------------------
		-- Prettier/Prettierd: inherit default args, just swap the command
		conform.formatters.prettier = {
			inherit = true,
			command = prettier_cmd,
		}

		-- Stylua: inherit defaults; just set the command
		conform.formatters.stylua = {
			inherit = true,
			command = stylua_cmd,
		}

		-- shfmt: set the command + 2-space indent
		conform.formatters.shfmt = {
			inherit      = true,
			command      = shfmt_cmd,
			prepend_args = { '-i', '2' },
		}

		---------------------------------------------------------------------------
		-- Manual “Make pretty” key (normal & visual)
		---------------------------------------------------------------------------
		vim.keymap.set({ 'n', 'v' }, '<Leader>p', function()
			conform.format({
				lsp_format = 'fallback',
				timeout_ms = 1500,
			})
		end, { desc = 'Make pretty with Conform' })
	end,
}
