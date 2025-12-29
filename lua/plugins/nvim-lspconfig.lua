-- nvim-lspconfig.lua based on new 0.12 system - symplified
-- from ChatGPT

return {
	'neovim/nvim-lspconfig',
	dependencies = { 'saghen/blink.cmp' },
	{ "folke/lazydev.nvim", ft = "lua", opts = {} }, -- from Gemini to speed things up
	event = "FileType",                             -- suggested by Gemini to speed up
	keys = {                                        -- suggested by Gemini to speed up
		-- Navigation
		{ 'gd',         vim.lsp.buf.definition,      'LSP: Go to definition' },
		{ 'gr',         vim.lsp.buf.references,      'LSP: References' },
		{ 'gD',         vim.lsp.buf.declaration,     'LSP: Go to declaration' },
		{ 'gi',         vim.lsp.buf.implementation,  'LSP: Go to implementation' },
		{ 'gt',         vim.lsp.buf.type_definition, 'LSP: Type definition' },

		-- Help / Actions
		{ 'K',          vim.lsp.buf.hover,           'LSP: Hover' },
		{ '<leader>r',  vim.lsp.buf.rename,          'LSP: Rename symbol' },
		{ '<leader>ca', vim.lsp.buf.code_action,     'LSP: Code action' }
	},

	config = function()
		-- 1. Setup Blink Capabilities
		local capabilities = require('blink.cmp').get_lsp_capabilities()

		vim.schedule(function() -- suggested by Gemini to speed things up
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
							codeLens = {
								enable = false, -- Disables the usage counts/numbers
							},
							hint = {
								enable = false, -- Disables the argument names
							},
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
		end)
	end,
}
