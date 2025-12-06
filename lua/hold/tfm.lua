-- tfm.lua

-- Created: 03/08/24

-- to run yzi from nvim

return {

  'rolv-apneseth/tfm.nvim',
  lazy = false,
  opts = {
    -- default file_manager = 'yazi',
    -- Replace netrw entirely
    -- Default: false
    replace_netrw = true,
    -- Enable creation of commands
    -- Default: false
    -- Commands:
    --   Tfm: selected file(s) will be opened in the current window
    --   TfmSplit: selected file(s) will be opened in a horizontal split
    --   TfmVsplit: selected file(s) will be opened in a vertical split
    --   TfmTabedit: selected file(s) will be opened in a new tab page
    enable_cmds = false,
    -- Custom keybindings only applied within the TFM buffer
    -- Default: {}
    keybindings = {
      ['<ESC>'] = 'q',
    },
    -- Customise UI. The below options are the default
    ui = {
      border = 'rounded',
      height = 1,
      width = 1,
      x = 0.5,
      y = 0.5,
    },
  },
  keys = {
    -- Make sure to change these keybindings to your preference,
    -- and remove the ones you won't use
    {
      '<leader>y',
      function()
        require('tfm').open()
      end,
      desc = 'yazi',
    },
    -- {
    --   '<leader>mh',
    --   ':TfmSplit<CR>',
    --   desc = 'TFM - horizonal split',
    -- },
    -- {
    --   '<leader>mv',
    --   ':TfmVsplit<CR>',
    --   desc = 'TFM - vertical split',
    -- },
    -- {
    --   '<leader>mt',
    --   ':TfmTabedit<CR>',
    --   desc = 'TFM - new tab',
    -- },
  },
}
