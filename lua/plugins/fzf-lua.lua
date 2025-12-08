-- fuzzy finder

-- stylua: ignore
local function maps()
	Myfn.map('n', '<Leader>vb', '<cmd>lua require("fzf-lua").buffers()<cr>', { desc = 'buffers' })
	Myfn.map('n', '<Leader>vc', '<cmd>lua require("fzf-lua").command_history()<cr>', { desc = 'commands' })
	Myfn.map('n', '<Leader>vf', '<cmd>lua require("fzf-lua").files()<cr>', { desc = 'find files' })
	-- Myfn.map('n', '<Leader>f', '<cmd>lua require("fzf-lua").files()<cr>', { desc = 'find files' })
	Myfn.map('n', '<Leader>vg', '<cmd>lua require("fzf-lua").grep_visual()<cr>', { desc = 'grep' })
	Myfn.map('n', '<Leader>vk', '<cmd>lua require("fzf-lua").keymaps()<cr>', { desc = 'keymaps' })
	Myfn.map('n', '<Leader>vl', '<cmd>lua require("fzf-lua").changes()<cr>', { desc = 'line changes' })
	Myfn.map('n', '<Leader>vm', '<cmd>lua require("fzf-lua").marks()<cr>', { desc = 'marks' })
	Myfn.map('n', '<Leader>vo', '<cmd>lua require("fzf-lua").oldfiles()<cr>', { desc = 'oldfiles' })
	Myfn.map('n', '<Leader>vq', '<cmd>lua require("fzf-lua").quickfix()<cr>', { desc = 'quickfix' })
	Myfn.map('n', '<Leader>vr', '<cmd>lua require("fzf-lua").resume()<cr>', { desc = 'resume' })
	Myfn.map('n', '<Leader>vs', '<cmd>lua require("fzf-lua").registers()<cr>', { desc = 'registers' })
	Myfn.map('n', '<Leader>vw', '<cmd>lua require("fzf-lua").grep_cword()<cr>', { desc = 'grep word' })
	-- Myfn.map('n', '<Leader>vz', '<cmd>lua require("fzf-lua").zoxide()<cr>', { desc = 'zoxide' })
	Myfn.map('n', '<Leader>z', '<cmd>lua require("fzf-lua").zoxide()<cr>', { desc = 'zoxide' })
end

maps()

return {
	'ibhagwan/fzf-lua',
	lazy = false,
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		-- next 2 lines for telescope
		-- require('fzf-lua').setup({ 'fzf-native' })
		-- require('fzf-lua').setup({ 'telescope' })
		-- fzf-vim sets up :Files etc. seems to be best
		require('fzf-lua').setup({ 'fzf-vim' })
		local actions = require('fzf-lua.actions')
		require('fzf-lua').setup({
			defaults = { silent = true },
			winopts = {
				-- split         = 'belowright new',-- open in a split instead?
				--     "belowright new"  : split below
				--     "aboveleft new"   : split above
				--     "belowright vnew" : split right
				--     "aboveleft vnew   : split left
				--     only valid when using a float window
				--     (i.e. when 'split' is not defined, default)
				height = 0.80, -- window height
				width = 0.85,
				row = 0.58, -- window row position (0=top, 1=bottom)
				col = 0.50, -- window col position (0=left, 1=right)
				border = 'rounded',
				fullscreen = false, -- start fullscreen
				preview = {
					border = 'border', -- border|noborder, applies only to
					wrap = 'wrap', -- wrap|nowrap
					hidden = 'nohidden', -- hidden|nohidden
					vertical = 'down:45%', -- up|down:size
					horizontal = 'right:60%', -- right|left:size
					layout = 'horizontal', -- horizontal|vertical|flex
					flip_columns = 120, -- #cols to switch to horizontal on flex
					title = true, -- preview border title (file/buf)?
					title_pos = 'center', -- left|center|right, title alignment
					scrollbar = false, -- `false` or string:'float|border'
					scrolloff = '-2', -- float scrollbar offset from right
					scrollchars = { '█', '' }, -- scrollbar chars ({ <full>, <empty> }
					delay = 100, -- delay(ms) displaying the preview
					winopts = { -- builtin previewer window options
						number = false,
						relativenumber = false,
						cursorline = true,
						cursorlineopt = 'both',
						cursorcolumn = false,
						signcolumn = 'no',
						list = false,
						foldenable = true,
						foldmethod = 'expr',
						delay = 0,
					},
				},
			},
			keymap = {
				-- These override the default tables completely
				-- no need to set to `false` to disable a bind
				-- delete or modify is sufficient
				builtin = {
					['<F1>'] = 'toggle-help',
					['<F2>'] = 'toggle-fullscreen',
					['<F3>'] = 'toggle-preview-wrap',
					['<F4>'] = 'toggle-preview',
					['<F5>'] = 'toggle-preview-ccw',
					['<F6>'] = 'toggle-preview-cw',
					['<S-down>'] = 'preview-page-down',
					['<S-up>'] = 'preview-page-up',
					['<S-left>'] = 'preview-page-reset',
				},
				fzf = {
					['ctrl-z'] = 'abort',
					['ctrl-u'] = 'unix-line-discard',
					['ctrl-f'] = 'half-page-down',
					['ctrl-b'] = 'half-page-up',
					['ctrl-a'] = 'beginning-of-line',
					['ctrl-e'] = 'end-of-line',
					['alt-a'] = 'toggle-all',
					['f3'] = 'toggle-preview-wrap',
					['f4'] = 'toggle-preview',
					['shift-down'] = 'preview-page-down',
					['shift-up'] = 'preview-page-up',
				},
			},
			actions = {
				-- These override the default
				-- no need to set to `false` to disable an action
				-- delete or modify is sufficient
				files = {
					['default'] = actions.file_edit,
					['ctrl-s'] = actions.file_split,
					['ctrl-v'] = actions.file_vsplit,
					['ctrl-t'] = actions.file_tabedit,
					['alt-q'] = actions.file_sel_to_qf,
					['ctrl-q'] = actions.file_sel_to_qf,
					['alt-l'] = actions.file_sel_to_ll,
					-- ['alt-h'] = function(_, opts)
					['ctrl-h'] = function(_, opts)
						opts.hidden = not opts.hidden
						if opts.hidden then
							vim.notify("Hidden files: ON", vim.log.levels.INFO)
						else
							vim.notify("Hidden files: OFF", vim.log.levels.INFO)
						end
						-- Re-run the picker with the new hidden setting
						require('fzf-lua').files(opts)
					end,
				},
				buffers = {
					['default'] = actions.buf_edit,
					['ctrl-s'] = actions.buf_split,
					['ctrl-v'] = actions.buf_vsplit,
					['ctrl-t'] = actions.buf_tabedit,
				},
			},
			fzf_opts = {
				-- options are sent as `<left>=<right>`
				-- set to `false` to remove a flag
				-- set to '' for a non-value flag
				-- for raw args use `fzf_args` instead
				-- ['--ansi'] = '',
				['--info'] = 'inline',
				['--height'] = '100%',
				['--layout'] = 'reverse',
				['--border'] = 'none',
			},
			previewers = {
				cat = {
					cmd = 'cat',
					args = '--number',
				},
				bat = {
					cmd = 'bat',
					args = '--color=always --style=numbers,changes',
				},
				head = {
					cmd = 'head',
					args = nil,
				},
				man = {
					--NOTE: remove the `-c` flag when using man-db
					-- replace with `man -P cat %s | col -bx` on OSX
					cmd = 'man -c %s | col -bx',
				},
				builtin = {
					syntax = true,           -- preview syntax highlight?
					syntax_limit_l = 0,      -- syntax limit (lines), 0=nolimit
					syntax_limit_b = 1024 * 1024, -- syntax limit (bytes), 0=nolimit
					limit_b = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
					-- previewer treesitter options:
					-- enable specific filetypes with: `{ enable = { "lua" } }
					-- exclude specific filetypes with: `{ disable = { "lua" } }
					-- disable fully with: `{ enable = false }`
					treesitter = { enabled = true, disabled = {} },
					-- By default, the main window dimensions are calculted as if the
					-- preview is visible, when hidden the main window will extend to
					-- full size. Set the below to "extend" to prevent the main window
					-- from being modified when toggling the preview.
					toggle_behavior = 'default',
					-- Title transform function, by default only displays the tail
					-- title_fnamemodify = function(s) vim.fn.fnamemodify(s, ":t") end,
					-- preview extensions using a custom shell command:
					-- for example, use `viu` for image previews
					-- will do nothing if `viu` isn't executable
					extensions = {
						-- neovim terminal only supports `viu` block output
						-- ['png'] = { 'viu', '-b' },
						-- by default the filename is added as last argument
						-- if required, use `<file>` for argument positioning
						['svg'] = { 'chafa', '<file>' },
						['jpg'] = { 'chafa', '<file>' },
						['png'] = { 'chafa', '<file>' },
					},
				},
			},
			--[[ PROVIDERS SETUP
         [ use `defaults` (table or function) if you wish to set 'global-provider' defaults
         [ for exmaple, disabling file icons globally and open the quickfix list at the top
         [   defaults = {
         [     file_icons   = false,
         [     copen        = 'topleft copen', ]]
			--   },
			files = {
				--[[ previewer      = 'bat',          -- uncomment to override previewer
           [ (name from 'previewers' table)
           [ set to 'false' to disable ]]
				prompt = 'Files ❯ ',
				winopts = { preview = { layout = 'horizontal' } },
				header = false,  -- Disable header
				header_lines = {}, -- Ensure no extra lines appear
				multiprocess = true, -- run command in a separate process
				git_icons = false, -- show git icons?
				file_icons = true, -- show file icons?
				color_icons = true, -- colorize file|git icons
				--[[ path_shorten   = 1,              -- 'true' or number, shorten path?
           [ executed command priority is 'cmd' (if exists)
           [ otherwise auto-detect prioritizes `fd`:`rg`:`find`
           [ default options are controlled by 'fd|rg|find|_opts'
           [ NOTE: 'find -printf' requires GNU find ]]
				-- cmd = 'find . -type f -printf "%P\n"',
				-- find_opts = [[ -type f -not -path '*/\.git/*' -printf '%P\n']],
				rg_opts = '--color=never --files --hidden --follow -g "git"',
				fd_opts = "-t f -e lua -e md -e txt -e info -e sh -e profile -e desktop",
				--[[ by default, cwd appears in the header only if {opts} contain a cwd
           [ parameter to a different folder than the current working directory
           [ uncomment if you wish to force display of the cwd as part of the
           [ query prompt string (fzf.vim style), header line or bothi]]
				-- cwd_header = true,
				cwd_prompt = true,
				cwd_prompt_shorten_len = 32,    -- shorten prompt beyond this length
				cwd_prompt_shorten_val = 1,     -- shortened path parts length
				toggle_ignore_flag = '--no-ignore', -- flag toggled in `actions.toggle_ignore`
				actions = {
					--[[ inherits from 'actions.files', here we can override
             [ or set bind to 'false' to disable a default action
             [   ["default"]   = actions.file_edit,
             [ custom actions are available too
             [   ["ctrl-y"]    = function(selected) print(selected[1]) end,
             [ action to toggle `--no-ignore`, requires fd or rg installed
             -- [   ["ctrl-g"]    = { actions.toggle_ignore }, ]]
				},
			},
			marks = {
				winopts = { preview = { layout = 'vertical' } },
			},
			grep = {
				prompt = 'grep > ',
				input_prompt = 'Grep For ❯ ',
				-- wide layout with preview on bottom
				winopts = { preview = { layout = 'horizontal' } },
				multiprocess = true, -- run command in a separate process
				git_icons = false, -- show git icons?
				file_icons = true, -- show file icons?
				color_icons = true, -- colorize file|git icons
				--[[ executed command priority is 'cmd' (if exists)
           [ otherwise auto-detect prioritizes `rg` over `grep`
           [ default options are controlled by 'rg|grep_opts'
           [ cmd            = "rg --vimgrep", ]]
				grep_opts = '--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e',
				-- rg_opts           = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
				rg_opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e',
				--[[ set to 'true' to always parse globs in both 'grep' and 'live_grep'
           [ search strings will be split using the 'glob_separator' and translated
           [ to '--iglob=' arguments, requires 'rg'
           [ can still be used when 'false' by calling 'live_grep_glob' directly ]]
				rg_glob = false,       -- default to glob parsing?
				glob_flag = '--iglob', -- for case sensitive globs use '--glob'
				glob_separator = '%s%-%-', -- query separator pattern (lua): ' --'
				--[[ advanced usage: for custom argument parsing define
           [ 'rg_glob_fn' to return a pair:
           [   first returned argument is the new search query
           [   second returned argument are addtional rg flags
           [ rg_glob_fn = function(query, opts)
           [   ...
           [   return new_query, flags
           [ end, ]]
				actions = {
					--[[ actions inherit from 'actions.files' and merge
             [ this action toggles between 'grep' and 'live_grep' ]]
					['ctrl-g'] = { actions.grep_lgrep },
				},
				no_header = true, -- hide grep|cwd header?
				no_header_i = false, -- hide interactive header?
			},
			args = {
				prompt = 'Args ❯ ',
				files_only = true,
				-- actions inherit from 'actions.files' and merge
				actions = { ['ctrl-x'] = { fn = actions.arg_del, reload = true } },
			},
			oldfiles = {
				prompt = 'Recent ❯ ',
				cwd_only = false,
				winopts = { preview = { layout = 'horizontal' } },
				stat_file = true,            -- verify files exist on disk
				include_current_session = false, -- include bufs from current session
			},
			buffers = {
				prompt = 'Buffers❯ ',
				file_icons = true, -- show file icons?
				color_icons = true, -- colorize file|git icons
				sort_lastused = true, -- sort buffers() by last used
				show_unloaded = true, -- show unloaded buffers
				cwd_only = false, -- buffers for the cwd only
				cwd = nil,        -- buffers list for a given dir
				actions = {
					--[[ actions inherit from 'actions.buffers' and merge
             [ by supplying a table of functions we're telling
             [ fzf-lua to not close the fzf window, this way we
             [ can resume the buffers picker on the same window
             [ eliminating an otherwise unaesthetic win "flash" ]]
					['ctrl-x'] = { fn = actions.buf_del, reload = true },
				},
			},
			tabs = {
				prompt = 'Tabs❯ ',
				tab_title = 'Tab',
				tab_marker = '<<',
				file_icons = true, -- show file icons?
				color_icons = true, -- colorize file|git icons
				actions = {
					-- actions inherit from 'actions.buffers' and merge
					['default'] = actions.buf_switch,
					['ctrl-x'] = { fn = actions.buf_del, reload = true },
				},
				fzf_opts = {
					-- hide tabnr
					['--delimiter'] = '[\\):]',
					['--with-nth'] = '2..',
				},
			},
			lines = {
				-- previewer = 'builtin', -- set to 'false' to disable
				previewer = 'false', -- set to 'false' to disable
				prompt = 'Lines❯ ',
				show_unloaded = true, -- show unloaded buffers
				show_unlisted = false, -- exclude 'help' buffers
				no_term_buffers = true, -- exclude 'term' buffers
				winopts = { preview = { layout = 'vertical' } },
				fzf_opts = {
					--[[ do not include bufnr in fuzzy matching
             [ tiebreak by line no. ]]
					['--delimiter'] = '[\\]:]',
					['--nth'] = '2..',
					['--tiebreak'] = 'index',
					['--tabstop'] = '1',
				},
				-- actions inherit from 'actions.buffers' and merge
				actions = {
					['default'] = actions.buf_edit_or_qf,
					['alt-q'] = actions.buf_sel_to_qf,
					['alt-l'] = actions.buf_sel_to_ll,
				},
			},
			blines = {
				previewer = 'builtin', -- set to 'false' to disable
				prompt = 'BLines❯ ',
				show_unlisted = true, -- include 'help' buffers
				no_term_buffers = false, -- include 'term' buffers
				start = 'cursor',    -- start display from cursor?
				fzf_opts = {
					-- hide filename, tiebreak by line no.
					['--delimiter'] = '[\\]:]',
					['--with-nth'] = '2..',
					['--tiebreak'] = 'index',
					['--tabstop'] = '1',
				},
				-- actions inherit from 'actions.buffers' and merge
				actions = {
					['default'] = actions.buf_edit_or_qf,
					['alt-q'] = actions.buf_sel_to_qf,
					['alt-l'] = actions.buf_sel_to_ll,
				},
			},
			tags = {
				prompt = 'Tags❯ ',
				ctags_file = nil, -- auto-detect from tags-option
				multiprocess = true,
				file_icons = true,
				git_icons = false,
				color_icons = true,
				-- 'tags_live_grep' options, `rg` prioritizes over `grep`
				rg_opts = '--no-heading --color=always --smart-case',
				grep_opts = '--color=auto --perl-regexp',
				actions = {
					--[[ actions inherit from 'actions.files' and merge
             [ this action toggles between 'grep' and 'live_grep' ]]
					['ctrl-g'] = { actions.grep_lgrep },
				},
				no_header = false, -- hide grep|cwd header?
				no_header_i = false, -- hide interactive header?
			},
			btags = {
				prompt = 'BTags❯ ',
				ctags_file = nil,  -- auto-detect from tags-option
				ctags_autogen = false, -- dynamically generate ctags each call
				multiprocess = true,
				file_icons = true,
				git_icons = false,
				color_icons = true,
				rg_opts = '--no-heading --color=always',
				grep_opts = '--color=auto --perl-regexp',
				fzf_opts = {
					['--delimiter'] = '[\\]:]',
					['--with-nth'] = '2..',
					['--tiebreak'] = 'index',
				},
				-- actions inherit from 'actions.files'
			},
			colorschemes = {
				prompt = 'Colorschemes❯ ',
				live_preview = true, -- apply the colorscheme on preview?
				actions = { ['default'] = actions.colorscheme },
				winopts = { height = 0.55, width = 0.30 },
				--[[ uncomment to ignore colorschemes names (lua patterns)
           [ ignore_patterns   = { "^delek$", "^blue$" },
           [ uncomment to execute a callback after interface is closed
           [ e.g. a call to reset statusline highlights
           [ post_reset_cb     = function() ... end, ]]
			},
			zoxide = {
				prompt = 'zoxide> ',
				winopts = { preview = { layout = 'vertical' } },
				actions = {
					['default'] = function(selected)
						if not selected or #selected == 0 then
							print('Error: No selection made')
							return
						end

						-- Extract the last field, assuming tab separation between score and path
						local dir = selected[1]:match('[^\t]+$') -- Grabs the last tab-separated value

						-- Trim any leading/trailing spaces
						dir = dir and dir:gsub('^%s*(.-)%s*$', '%1') or nil

						if dir and vim.fn.isdirectory(dir) == 1 then
							vim.cmd('cd ' .. vim.fn.fnameescape(dir))
							require('fzf-lua').files({ cwd = dir })
						else
							print('Error: Directory not found -', dir)
						end
					end,
				},
			},
			keymaps = {
				prompt = 'Keymaps> ',
				winopts = { preview = { layout = 'vertical' } },
				fzf_opts = { ['--tiebreak'] = 'index' },
				--[[ by default, we ignore <Plug> and <SNR> mappings
           [ set `ignore_patterns = false` to disable filtering ]]
				ignore_patterns = { '^<SNR>', '^<Plug>' },
				actions = {
					['default'] = actions.keymap_apply,
					['ctrl-s'] = actions.keymap_split,
					['ctrl-v'] = actions.keymap_vsplit,
					['ctrl-t'] = actions.keymap_tabedit,
				},
			},
			quickfix = {
				file_icons = true,
				git_icons = false,
			},
			quickfix_stack = {
				prompt = 'Quickfix Stack> ',
				marker = '>', -- current list marker
			},
			lsp = {
				prompt_postfix = '❯ ', -- will be appended to the LSP label
				-- to override use 'prompt' instead
				cwd_only = false, -- LSP/diagnostics for cwd only?
				async_or_timeout = 5000, -- timeout(ms) or 'true' for async calls
				file_icons = true,
				git_icons = false,
				--[[ The equivalent of using `includeDeclaration` in lsp buf calls, e.g:
           [ :lua vim.lsp.buf.references({includeDeclaration = false}) ]]
				includeDeclaration = true, -- include current declaration in LSP context
				-- settings for 'lsp_{document|workspace|lsp_live_workspace}_symbols'
				symbols = {
					async_or_timeout = true, -- symbols are async by default
					symbol_style = 1,   -- style for document/workspace symbols
					--[[ false: disable,    1: icon+kind
             [     2: icon only,  3: kind only
             [ NOTE: icons are extracted from
             [ vim.lsp.protocol.CompletionItemKind
             [ icons for symbol kind
             [ see https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
             [ see https://github.com/neovim/neovim/blob/829d92eca3d72a701adc6e6aa17ccd9fe2082479/runtime/lua/vim/lsp/protocol.lua#L117 ]]
					symbol_icons = {
						File = '󰈙',
						Module = '',
						Namespace = '󰦮',
						Package = '',
						Class = '󰆧',
						Method = '󰊕',
						Property = '',
						Field = '',
						Constructor = '',
						Enum = '',
						Interface = '',
						Function = '󰊕',
						Variable = '󰀫',
						Constant = '󰏿',
						String = '',
						Number = '󰎠',
						Boolean = '󰨙',
						Array = '󱡠',
						Object = '',
						Key = '󰌋',
						Null = '󰟢',
						EnumMember = '',
						Struct = '󰆼',
						Event = '',
						Operator = '󰆕',
						TypeParameter = '󰗴',
					},
					--[[ colorize using Treesitter '@' highlight groups ("@function", etc).
             [ or 'false' to disable highlighting ]]
					symbol_hl = function(s)
						return '@' .. s:lower()
					end,
					-- additional symbol formatting, works with or without style
					symbol_fmt = function(s, opts)
						return '[' .. s .. ']'
					end,
					-- prefix child symbols. set to any string or `false` to disable
					child_prefix = true,
				},
				code_actions = {
					prompt = 'Code Actions> ',
					async_or_timeout = 5000,
					winopts = {
						row = 0.40,
						height = 0.35,
						width = 0.60,
					},
				},
				finder = {
					prompt = 'LSP Finder> ',
					fzf_opts = { ['--info'] = 'default' },
					file_icons = true,
					color_icons = true,
					git_icons = false,
					async = true,         -- async by default
					silent = true,        -- suppress "not found"
					separator = '| ',     -- separator after provider prefix, `false` to disable
					includeDeclaration = true, -- include current declaration in LSP context
					--[[ by default display all LSP locations
             [ to customize, duplicate table and delete unwanted providers ]]
					providers = {
						{ 'references',      prefix = require('fzf-lua').utils.ansi_codes.blue('ref ') },
						{ 'definitions',     prefix = require('fzf-lua').utils.ansi_codes.green('def ') },
						{ 'declarations',    prefix = require('fzf-lua').utils.ansi_codes.magenta('decl') },
						{ 'typedefs',        prefix = require('fzf-lua').utils.ansi_codes.red('tdef') },
						{ 'implementations', prefix = require('fzf-lua').utils.ansi_codes.green('impl') },
						{ 'incoming_calls',  prefix = require('fzf-lua').utils.ansi_codes.cyan('in  ') },
						{ 'outgoing_calls',  prefix = require('fzf-lua').utils.ansi_codes.yellow('out ') },
					},
				},
			},
			diagnostics = {
				prompt = 'Diagnostics❯ ',
				cwd_only = false,
				file_icons = true,
				git_icons = false,
				diag_icons = true,
				diag_source = true, -- display diag source (e.g. [pycodestyle])
				icon_padding = '', -- add padding for wide diagnostics signs
				multiline = true, -- concatenate multi-line diags into a single line
				--[[         set to `false` to display the first line only
   [         by default icons and highlights are extracted from 'DiagnosticSignXXX'
   [         and highlighted by a highlight group of the same name (which is usually
   [         set by your colorscheme, for more info see:
   [           :help DiagnosticSignHint'
   [           :help hl-DiagnosticSignHint'
   [         only uncomment below if you wish to override the signs/highlights
   [         define only text, texthl or both (':help sign_define()' for more info)
   [         signs = {
   [           ['Error'] = { text = '', texthl = 'DiagnosticError' },
   [           ['Warn']  = { text = '', texthl = 'DiagnosticWarn' },
   [           ['Info']  = { text = '', texthl = 'DiagnosticInfo' },
   [           ['Hint']  = { text = '󰌵', texthl = 'DiagnosticHint' },
   [         },
   [         limit to specific severity, use either a string or num:
   [
   [           2 or 'information'
   [           3 or 'warning'
   [           4 or 'error'
   [         severity_only:   keep any matching exact severity
   [         severity_limit:  keep any equal or more severe (lower)
   [         severity_bound:  keep any equal or less severe (higher) ]]
			},
			complete_path = {
				cmd = nil, -- default: auto detect fd|rg|find
				complete = { ['default'] = actions.complete },
			},
			complete_file = {
				cmd = nil, -- default: auto detect rg|fd|find
				file_icons = true,
				color_icons = true,
				git_icons = false,
				-- actions inherit from 'actions.files' and merge
				actions = { ['default'] = actions.complete },
				-- previewer hidden by default
				winopts = { preview = { hidden = 'hidden' } },
			},
			--[[       uncomment to use fzf native previewers
   [       (instead of using a neovim floating window)
   [       manpages = { previewer = "man_native" },
   [       helptags = { previewer = "help_native" },
   [
   [       optional override of file extension icon colors
   [       available colors (terminal):
   [          clear, bold, black, red, green, yellow
   [          blue, magenta, cyan, grey, dark_grey, white ]]
			file_icon_colors = {
				['sh'] = 'green',
			},
			--[[ padding can help kitty term users with
         [ double-width icon rendering ]]
			file_icon_padding = '',
			--[[ uncomment if your terminal/font does not support unicode character
         [ 'EN SPACE' (U+2002), the below sets it to 'NBSP' (U+00A0) instead
         [ nbsp = '\xc2\xa0', ]]
		})
	end,
}
