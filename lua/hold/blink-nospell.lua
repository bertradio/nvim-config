-- blink.lua - without blink spelling dictionary
-- Created: 12/23/24

return {

	'saghen/blink.cmp',
	version = '1.*',
	dependencies = {
		'rafamadriz/friendly-snippets',
		'nvim-lua/plenary.nvim',
	},

	opts = {

		-- keymap presets
		keymap = { preset = 'super-tab' },

		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = 'mono',
		},

		-- show fields while filing in a snippet
		signature = { enabled = true, window = { border = 'rounded' } },

		completion = {
			menu = {
				border = 'rounded',
				-- set columns to display in menu
				draw = {
					columns = {
						{ 'label',      'label_description', gap = 1 },
						{ 'kind_icon' },
						{ 'kind' },
						{ 'source_name' },
					},
				},
			},
			documentation = { auto_show = true, window = { border = 'rounded' } },
			trigger = { show_in_snippet = false },
			list = { selection = { preselect = false, auto_insert = false } },
		},

		sources = {
			-- override default sources for different filetypes
			-- opts_override = { 'sources.default' },
			-- for all filetypes other than those in per_filetype
			default = { 'buffer', 'path' },
			-- stylua: ignore
			-- for specific filetypes
			per_filetype = {
				lua      = { 'buffer', 'lsp', 'path', 'snippets' },
				sh       = { 'buffer', 'lsp', 'path', 'snippets' },
				markdown = { 'buffer', 'path' },
				text     = { 'buffer', 'path' },
				ps1      = { 'lsp', 'buffer', 'path', 'snippets' },
			},
			-- stylua: ignore
			providers = {
				buffer   = { score_offset = 10 },
				lsp      = { score_offset = 3 },
				path     = { score_offset = 2 },
				snippets = { score_offset = 1 },
				cmdline  = { score_offset = 1 },
			},
		},

		-- disable fuzzy matching as much as possible
		-- from ChatGPT needs fuzzy{} and filters{}
		-- fuzzy = {
		--   implementation = 'lua',
		--   use_frecency = false,
		--   use_proximity = false,
		--   prebuilt_binaries = { download = false },
		--   sorts = { 'exact', 'sort_text', 'score' },
		-- },
		-- filters = {
		--   custom = function(entry, input)
		--     -- Only show if the label starts with the full input
		--     return vim.startswith(entry.label or '', input)
		--   end,
		-- },
		-- end disable fuzzy matching

		fuzzy = {
			implementation = 'prefer_rust_with_warning',
			-- Frecency tracks the most recently/frequently used items and boosts the score of the item
			-- Note, this does not apply when using the Lua implementation.
			use_frecency = true,
			-- Proximity bonus boosts the score of items matching nearby words
			-- Note, this does not apply when using the Lua implementation.
			use_proximity = true,
			-- sorts = {
			--   -- (optionally) always prioritize exact matches
			--   'exact',
			--   'sort_text',
			--   'score',
			-- },
			prebuilt_binaries = { download = true },
		},
	},
}
