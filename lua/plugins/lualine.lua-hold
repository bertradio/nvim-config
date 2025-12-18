-- Configure status line
-- Code for Oil from ChatGPT
-- (Merged: Oil buffers in tabline show current directory as their label)

-- >>>>>>>>>> local display functions for use on status line <<<<<<<<<<<<<<

-- display number of words in buffer
local function getWords()
	local wc = vim.fn.wordcount()
	if wc['visual_words'] then -- if in visual mode, show words in selection
		return wc['visual_words'] .. ' Words selected'
	else                       -- otherwise words in all of the document
		return wc['words'] .. ' Words'
	end
end

-- display s+ if spellcheck is on
local function spellOn()
	if vim.wo.spell == true then
		return [[s+]]
	else
		return ''
	end
end

-- display when recording a macro
local function show_macro_recording()
	local recording_register = vim.fn.reg_recording()
	if recording_register == '' then
		return ''
	else
		return 'Recording @' .. recording_register
	end
end

-- Force lualine to refresh when recording starts/stops
vim.api.nvim_create_autocmd('RecordingEnter', {
	callback = function()
		require('lualine').refresh({ place = { 'statusline' } })
	end,
})
vim.api.nvim_create_autocmd('RecordingLeave', {
	callback = function()
		require('lualine').refresh({ place = { 'statusline' } })
	end,
})

---------------------------------
-- Oil buffer tab title formatter
---------------------------------

-- Toggle: show full path (with ~) vs just folder name
local OIL_TAB_SHOW_FULL_PATH = true

local function dir_from_oil_bufname(bufnr)
	local raw = vim.api.nvim_buf_get_name(bufnr) or ''
	raw = raw:gsub('^oil://', ''):gsub('^oil%-trash://', '')
	raw = raw:gsub('^/*', '') -- Windows: oil:///C:/...
	return raw
end

local function oil_tab_fmt(name, context)
	local bufnr = context and context.bufnr or nil
	if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
		return name
	end
	if vim.bo[bufnr].filetype ~= 'oil' then
		return name
	end

	local dir
	local ok_oil, oil = pcall(require, 'oil')
	if ok_oil and type(oil.get_current_dir) == 'function' then
		local ok_dir, got = pcall(oil.get_current_dir, bufnr)
		dir = ok_dir and got or oil.get_current_dir()
	end
	if not dir or dir == '' then
		dir = dir_from_oil_bufname(bufnr)
	end

	if not OIL_TAB_SHOW_FULL_PATH then
		-- Just display the word Oil if false
		-- local short = vim.fn.fnamemodify(dir, ':~')
		return 'Oil' --  .. vim.fn.fnamemodify(short, ':t')
	else
		return 'Oil: ' .. vim.fn.fnamemodify(dir, ':~')
	end
end

-----------------------------

return {

	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },

	config = function()
		-- stylua: ignore
		require('lualine').setup({
			options = {
				theme                = 'catppuccin',
				icons_enabled        = true,
				-- section_separators   = { left = ']', right = '' },
				-- section_separators = { left = '', right  = '' },
				component_separators = { left = '', right = '' },
				disabled_filetypes   = {
					statusline = {},
					winbar     = {},
				},
				ignore_focus         = {},
				always_divide_middle = true,
				globalstatus         = false,
				refresh              = {
					statusline = 100,
					tabline    = 100,
				},
			},

			-- status line config
			sections = {

				-- left side
				lualine_a = { 'mode' },
				lualine_b = { Myfn.short_cwd },
				lualine_c = {},

				-- right side
				lualine_x = {
					{ show_macro_recording },
					{ spellOn },
				},
				lualine_y = {},
				lualine_z = { getWords },
			},

			-- disable winbar
			winbar = {},
			inactive_winbar = {},

			extensions = { 'neo-tree', 'lazy', 'mason', 'quickfix' },

			-- tabline config
			tabline = {
				-- just use left side of top line
				lualine_a = {
					{
						'buffers',
						mode                 = 0,
						tab_max_length       = 40,
						max_length           = 100,
						show_modified_status = true,
						symbols              = {
							modified = ' ●',
						},
						use_mode_colors      = true,
						fmt                  = oil_tab_fmt, -- <<< Show Oil's current directory as its tab title
					},
				},
			},

		})
	end,
}
