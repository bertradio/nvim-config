--    ╭────────────────────────────╮
--    │          yazi.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
--
-- Created: 04/23/24

vim.pack.add({
  Gh('mikavilpas/yazi.nvim'),
  Gh('nvim-lua/plenary.nvim'),
})

local yazi = require('yazi')

Kset('n', '<Leader>y', function()
  yazi.yazi(nil, vim.fn.getcwd())
end, { desc = 'Yazi' })

vim.api.nvim_create_user_command('Yazi', function()
  yazi.yazi()
end, {})

vim.api.nvim_create_user_command('YaziHere', function()
  yazi.yazi(nil, vim.fn.getcwd())
end, {})

-- stylua: ignore 
yazi.setup({
  open_for_directories    = false,
  use_yazi_client_id_flag = true,
  enable_mouse_support    = true,

  -- the type of border to use for the floating window
  yazi_floating_window_border = 'double',

  -- floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
  floating_window_scaling_factor = 0.85,

  hooks = {
    -- if yazi not opening file, change cwd to one in yazi
    yazi_closed_successfully = function(chosen_file, config, state)
      if chosen_file == nil and state.last_directory.filename then
        vim.fn.chdir(state.last_directory.filename)
      end
    end,
  },

  -- stylua: ignore
  keymaps = {
    copy_relative_path_to_selected_files = '<c-y>',
    cycle_open_buffers                   = '<tab>',
    grep_in_directory                    = '<c-g>',
    open_file_in_horizontal_split        = '<c-x>',
    open_file_in_vertical_split          = '<c-v>',
    replace_in_directory                 = 'false',
    send_to_quickfix_list                = '<c-q>',
    show_help                            = '<f1>',
  },
})
