-- lua/plugins/catppuccin.lua
-- code from ChatGPT for fold icons

return {
	'catppuccin/nvim',
	name     = 'catppuccin',
	priority = 1000,
	lazy     = false,
	config   = function()
		vim.opt.termguicolors = true

		require('catppuccin').setup({
			flavour                = 'mocha',
			transparent_background = false,
			show_end_of_buffer     = false,
			no_italic              = false,
			no_bold                = false,
			styles                 = { comments = { 'italic' } },

			highlight_overrides    = {
				all = function(colors)
					return {
						FoldColumn = { fg = colors.lavender, bg = colors.none },
						Folded     = { fg = colors.flamingo, bg = colors.base },
						SignColumn = { bg = colors.none },
					}
				end,
				mocha = function(colors)
					return {
						Comment    = { bg = '#1f1f1f', style = { 'italic' } },
						Cursor     = { bg = '#a8a8a8' },
						CursorLine = { bg = '#273746' },
						LineNr     = { bg = '#262626', fg = 'Grey' },
						Folded     = { bg = '#262626', fg = '#ffffff' },
						FoldColumn = { bg = '#262626', fg = colors.sapphire },
					}
				end,
			},

			integrations           = {
				blink_cmp          = { style = 'bordered' },
				blink_indent       = true,
				markdown           = true,
				noice              = true,
				neotree            = true,
				pounce             = true,
				treesitter         = true,
				rainbow_delimiters = true,
				indent_blankline   = {
					enabled               = true,
					scope_color           = '',
					colored_indent_levels = false,
				},
				mini               = { enabled = true, indentscope_color = '' },
				snacks             = { enabled = true, indent_scope_color = '' },
				native_lsp         = {
					enabled = true,
					virtual_text = {
						errors      = { 'italic' },
						hints       = { 'italic' },
						warnings    = { 'italic' },
						information = { 'italic' },
						ok          = { 'italic' },
					},
					underlines = {
						errors      = { 'underline' },
						hints       = { 'underline' },
						warnings    = { 'underline' },
						information = { 'underline' },
						ok          = { 'underline' },
					},
					inlay_hints = { background = true },
				},
			},
		})

		-- Apply theme
		vim.cmd.colorscheme('catppuccin')
	end,
}
