-- cross platform code from ChatGPT to delete and move to recycle
-- other mods from ChatGPT

-- setup for excluded extensions list
local excluded_exts = require('config.file_exclude')

vim.g.neo_tree_remove_legacy_commands = 1

return {
	'nvim-neo-tree/neo-tree.nvim',
	branch = 'v3.x',
	-- event = 'VeryLazy',
	cmd = 'Neotree',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-tree/nvim-web-devicons',
		'MunifTanjim/nui.nvim',
	},

	keys = {
		{ '<Leader>[', '<cmd>Neotree left toggle<cr>',            desc = 'Neo-tree toggle' },
		{ '<Leader>n', '<cmd>Neotree float reveal_force_cwd<cr>', desc = 'Neo-tree floating' },
	},

	config = function()
		require('lua.hold.neo-tree').setup({
			enable_diagnostics = false,
			enable_git_status = false,
			enable_preview = true,
			git_status_async = false,
			log_level = 'warn',
			popup_border_style = 'double',
			sort_case_insensitive = true,

			source_selector = {
				sources = {
					{ source = 'filesystem' },
					{ source = 'buffers' },
				},
			},

			event_handlers = {
				{
					event = 'file_moved',
					handler = function(args)
						print('Moved to ', args.destination)
					end,
				},
			},

			default_component_configs = {
				name = {
					trailing_slash = false,
					highlight_opened_files = true,
				},
				indent = {
					with_markers = true,
					indent_marker = '│',
					last_indent_marker = '└',
					indent_size = 2,
				},
			},

			filesystem = {
				bind_to_cwd = true,
				follow_current_file = { enabled = false },
				cwd_target = { sidebar = 'tab', current = 'window' },
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = 'open_current',
				sync_root_with_cwd = true,
				filtered_items = {
					visible = false,
					force_visible_in_empty_folder = false,
					show_hidden_count = true,
					hide_dotfiles = true,
					hide_by_name = {},
					hide_by_pattern = excluded_exts,
				},
			},

			buffers = {
				follow_current_file = { enabled = true },
				group_empty_dirs = true,
				show_unloaded = true,
				window = {
					mappings = {
						-- keep your existing buffer mappings
						['<cr>'] = 'open',
						['o'] = 'open',
						['l'] = 'open',
						['h'] = 'close_node',
						['H'] = 'close_all_nodes',
						['d'] = 'buffer_delete',
						['R'] = 'refresh',
						['?'] = 'show_help',

						-- add these three lines to suppress the warnings in the Buffers source:
						['%'] = 'none', -- fuzzy_finder_directory (not valid in Buffers)
						['f'] = 'none', -- fuzzy_finder (not valid in Buffers)
						['/'] = 'none', -- filter_on_submit (not valid in Buffers)
					},
				},
			},

			window = {
				-- set sidebar width
				-- width = function()
				--   return math.floor(vim.o.columns * 0.30) -- 30% of the window width
				-- end,
				width = 33, -- settings that apply to float position only
				popup = {
					size = {
						height = '83%',
						width = '40%',
					},
				},
				mappings = {
					['[g'] = 'noop',
					[']g'] = 'noop',
					['t'] = 'noop',
					['w'] = 'noop',
					['<C-c>'] = 'set_root',
					['x'] = 'cut_to_clipboard',
					['p'] = 'paste_from_clipboard',
					['%'] = 'fuzzy_finder_directory',
					['<left>'] = 'navigate_up',
					['/'] = 'filter_on_submit',
					['f'] = 'fuzzy_finder',

					-- define move to recycle
					['d'] = {
						function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							if not path then
								print('No file selected')
								return
							end

							if vim.fn.confirm('Move to Recycle Bin?', '&Yes\n&No') ~= 1 then
								return
							end

							-- different commands for Windows and Linux
							local cmd
							if Myfn.is_windows() then
								if vim.loop.fs_stat(path).type == 'directory' then
									cmd =
											'powershell.exe -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(\''
											.. path
											.. "', 'OnlyErrorDialogs', 'SendToRecycleBin')\""
								else
									cmd =
											'powershell.exe -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(\''
											.. path
											.. "', 'OnlyErrorDialogs', 'SendToRecycleBin')\""
								end
							else -- for Linux
								local function trash_command(path)
									if vim.fn.executable('trash') == 1 then
										return 'trash-put "' .. path .. '"'
									else
										return nil
									end
								end

								-- error trap
								cmd = trash_command(path)
								if not cmd then
									print('No trash utility available')
									return
								end
							end

							local result = vim.fn.system(cmd)
							if vim.v.shell_error == 0 then
								print('Recycled: ' .. path)
								require('neo-tree.sources.manager').refresh('filesystem', state)
							else
								print('Failed to recycle: ' .. path)
								print(result)
							end
						end,
						desc = 'Send to Recycle Bin',
					},

					-- enable snacks LSP rename
					opts = function(_, opts)
						local function on_move(data)
							Snacks.rename.on_rename_file(data.source, data.destination)
						end
						local events = require('neo-tree.events')
						opts.event_handlers = opts.event_handlers or {}
						vim.list_extend(opts.event_handlers, {
							{ event = events.FILE_MOVED,   handler = on_move },
							{ event = events.FILE_RENAMED, handler = on_move },
						})
					end,

					-- re-define delete to be permanent
					-- ['D'] = {
					--   function(state)
					--     local node = state.tree:get_node()
					--     local path = node:get_id()
					--     if not path then
					--       print('No file selected')
					--       return
					--     end
					--
					--     if vim.fn.confirm('PERMANENTLY DELETE?', '&YES\n&NO') ~= 1 then
					--       return
					--     end
					--
					--     -- different delete command for Windows and Linux
					--     local cmd
					--     if Myfn.is_windows() then
					--       cmd = 'powershell -Command "Remove-Item -Path \'' .. path .. '\' -Recurse -Force"'
					--     else -- for Linux
					--       cmd = 'rm -rf "' .. path .. '"'
					--     end
					--
					--     local result = vim.fn.system(cmd)
					--     if vim.v.shell_error == 0 then
					--       print('Permanently deleted: ' .. path)
					--       require('neo-tree.sources.manager').refresh('filesystem', state)
					--     else
					--       print('Failed to delete: ' .. path)
					--       print(result)
					--     end
					--   end,
					--   desc = 'Permanently delete',
					-- },
				},
			},
		})
	end,
}
