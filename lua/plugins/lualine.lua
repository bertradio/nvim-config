-- Configure status line
-- Code for Oil from ChatGPT
-- (Merged: Oil buffers in tabline show current directory as their label)
-- Rewrite to optimize from Gemini

-- >>>>>>>>>> local display functions for use on status line <<<<<<<<<<<<<<

local function getWords()
  local wc = vim.fn.wordcount()
  if wc['visual_words'] then
    return wc['visual_words'] .. ' Words selected'
  else
    return wc['words'] .. ' Words'
  end
end

local function spellOn()
  return vim.wo.spell and 's+' or ''
end

local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == '' then
    return ''
  else
    return 'Recording @' .. recording_register
  end
end

---------------------------------
-- Oil buffer tab title formatter
---------------------------------

local OIL_TAB_SHOW_FULL_PATH = true

local function dir_from_oil_bufname(bufnr)
  local raw = vim.api.nvim_buf_get_name(bufnr) or ''
  raw = raw:gsub('^oil://', ''):gsub('^oil%-trash://', '')
  raw = raw:gsub('^/*', '')
  return raw
end

local function oil_tab_fmt(name, context)
  local bufnr = context and context.bufnr or nil
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].filetype ~= 'oil' then
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
    return 'Oil'
  else
    return 'Oil: ' .. vim.fn.fnamemodify(dir, ':~')
  end
end

-----------------------------

return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', lazy = true },
  },

  config = function()
    -- Refresh logic for macro recording
    vim.schedule(function()
      local grp = vim.api.nvim_create_augroup('LualineRecording', { clear = true })
      vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
        group = grp,
        callback = function()
          require('lualine').refresh({ place = { 'statusline' } })
        end,
      })
    end)

    require('lualine').setup({
      options = {
        theme = 'catppuccin',
        icons_enabled = true,
        -- RESTORED ARROW LOOK:
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'dashboard', 'alpha', 'starter' },
        },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 500,
          tabline = 500,
        },
      },

      sections = {
        lualine_a = { 'mode' },
        lualine_b = { (Myfn and Myfn.short_cwd) or 'branch' },
        lualine_c = {
          -- {
          -- 	'filename',
          -- 	file_status = true,
          -- 	path = 1,
          -- },
        },
        lualine_x = {
          { show_macro_recording, color = { fg = '#FFA500' } },
          { spellOn },
          -- 'encoding',
          -- 'filetype',
        },
        lualine_y = {},
        lualine_z = { getWords },
      },

      tabline = {
        lualine_a = {
          {
            'buffers',
            mode = 0,
            tab_max_length = 40,
            max_length = 100,
            show_modified_status = true,
            symbols = { modified = ' ●' },
            use_mode_colors = true,
            fmt = oil_tab_fmt,
          },
        },
      },

      extensions = { 'neo-tree', 'lazy', 'mason', 'quickfix', 'oil' },
    })
  end,
}
