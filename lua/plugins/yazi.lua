-- yazi.lua
--
-- Created: 04/23/24

Myfn.map('n', '<Leader>y', function()
	require('yazi').yazi(nil, vim.fn.getcwd())
end, { desc = 'Yazi' })

return {

	'mikavilpas/yazi.nvim',
	dependencies = {
		'folke/snacks.nvim',
	},

	cmd = { 'Yazi', 'YaziHere' },
	opts = {
		open_for_directories = true,
		use_yazi_client_id_flag = true,
		enable_mouse_support = true,
		-- the type of border to use for the floating window. Can be many values,
		-- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
		yazi_floating_window_border = 'double',
		-- more information, see :h nvim_open_win -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
		floating_window_scaling_factor = 0.8,
		hooks = {
			-- if yazi not opening file, change cwd to one in yazi
			yazi_closed_successfully = function(chosen_file, config, state)
				-- if state.last_directory.filename then
				if chosen_file == nil and state.last_directory.filename then
					-- vim.notify("Changing directory to " .. state.last_directory.filename)
					vim.fn.chdir(state.last_directory.filename)
				end
			end,
		},
		keymaps = {
			show_help = '<f1>',
			open_file_in_vertical_split = '<c-v>',
			open_file_in_horizontal_split = '<c-x>',
			open_file_in_tab = '<c-t>',
			-- grep_in_directory = '<c-s>',
			grep_in_directory = '<c-g>',
			-- replace_in_directory = '<c-g>',
			replace_in_directory = 'false',
			cycle_open_buffers = '<tab>',
			copy_relative_path_to_selected_files = '<c-y>',
			send_to_quickfix_list = '<c-q>',
			change_working_directory = '<c-\\>',
		},
		integrations = {
			grep_in_directory = function(directory)
				require('snacks.picker').grep({
					cwd = directory,
				})
			end,

			grep_in_selected_files = function(selected_files)
				require('snacks.picker').grep({
					files = selected_files,
				})
			end,
		},
	},
}
