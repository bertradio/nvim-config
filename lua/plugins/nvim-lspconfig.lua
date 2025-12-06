-- nvim-lspconfig.lua based on new 0.12 system - symplified
-- from ChatGPT

return {
	'neovim/nvim-lspconfig',
	dependencies = { 'saghen/blink.cmp' },
	event = { 'BufReadPre', 'BufNewFile' },
	config = function()
		-- 1. Setup Blink Capabilities
		local capabilities = require('blink.cmp').get_lsp_capabilities()

		-- 2. Define servers (CLEANER: No hardcoded paths!)
		local servers = {
			-- Lua
			lua_ls = {
				cmd = { 'lua-language-server' },
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'BOOT', 'Command', 'Snacks', 'Status', 'cx', 'ui', 'vim', 'ya' },
						},
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			},

			-- Standard servers
			marksman = {},
			taplo = {},
			vimls = {},
		}

		-- 3. Dynamic Server Configuration
		if Myfn and Myfn.is_windows and Myfn.is_windows() then
			servers.powershell_es = {
				bundle_path = vim.fn.stdpath('data') .. '/mason/packages/powershell-editor-services',
				shell = (vim.fn.executable('pwsh') == 1) and 'pwsh' or 'pwsh.exe',
				init_options = {
					enableProfileLoading = false,
					scriptAnalysis = false,
					telemetry = { enable = false },
				},
				filetypes = { 'ps1', 'psm1', 'psd1' },
			}
		else
			servers.bashls = {
				cmd = { 'bash-language-server', 'start' }, -- Simple command name
				filetypes = { 'sh', 'bash' },
			}
		end

		-- 4. Apply Configurations
		for name, config in pairs(servers) do
			config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})
			vim.lsp.config(name, config)
			vim.lsp.enable(name)
		end

		-- 5. LspAttach Autocommand
		vim.api.nvim_create_autocmd('LspAttach', {
			desc = 'LSP actions',
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				local bufnr = event.buf

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				-- Navigation
				map('n', 'gd', vim.lsp.buf.definition, 'LSP: Go to definition')
				map('n', 'gr', vim.lsp.buf.references, 'LSP: References')
				map('n', 'gD', vim.lsp.buf.declaration, 'LSP: Go to declaration')
				map('n', 'gi', vim.lsp.buf.implementation, 'LSP: Go to implementation')
				map('n', 'gt', vim.lsp.buf.type_definition, 'LSP: Type definition')

				-- Help / Actions
				map('n', 'K', vim.lsp.buf.hover, 'LSP: Hover')
				map('n', '<leader>r', vim.lsp.buf.rename, 'LSP: Rename symbol')
				map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'LSP: Code action')

				-- Highlight references
				if client and client.server_capabilities.documentHighlightProvider then
					local grp = vim.api.nvim_create_augroup('LspDocumentHighlight_' .. bufnr, { clear = true })
					vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
						group = grp,
						buffer = bufnr,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
						group = grp,
						buffer = bufnr,
						callback = vim.lsp.buf.clear_references,
					})
				end

				-- Native Inlay Hints
				if client and client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})

		-- 6. Diagnostics UI Config
		vim.diagnostic.config({
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			virtual_text = { spacing = 2, source = 'if_many' },
			float = { border = 'rounded', source = 'always' },
			signs = true,
		})
	end,
}
