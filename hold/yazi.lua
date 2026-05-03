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

Myfn.map('n', '<Leader>y', function()
  require('yazi').yazi(nil, vim.fn.getcwd())
end, { desc = 'Yazi' })

vim.api.nvim_create_user_command('Yazi', function()
  require('yazi').yazi()
end, {})

vim.api.nvim_create_user_command('YaziHere', function()
  require('yazi').yazi(nil, vim.fn.getcwd())
end, {})

-- stylua: ignore 
require('yazi').setup({
  open_for_directories    = true,
  use_yazi_client_id_flag = true,
  enable_mouse_support    = true,

  -- the type of border to use for the floating window
  yazi_floating_window_border = 'double',

  -- floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
  floating_window_scaling_factor = 1,

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
    show_help                            = '<f1>',
    open_file_in_vertical_split          = '<c-v>',
    open_file_in_horizontal_split        = '<c-x>',
    grep_in_directory                    = '<c-g>',
    replace_in_directory                 = 'false',
    cycle_open_buffers                   = '<tab>',
    copy_relative_path_to_selected_files = '<c-y>',
    send_to_quickfix_list                = '<c-q>',
  },
})
