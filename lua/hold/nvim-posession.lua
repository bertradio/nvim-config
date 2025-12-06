-- nvim.possession.lua

return {
  'gennaro-tedesco/nvim-possession',
  dependencies = {
    'ibhagwan/fzf-lua',
  },

  keys = {
    {
      '<leader>sl',
      function()
        require('nvim-possession').list()
      end,
      desc = '📌load session',
    },
    -- {
    --   '<leader>sm',
    --   function()
    --     -- use Oil to manage
    --     local sessdir = vim.fn.stdpath('data') .. '/sessions/'
    --     vim.cmd('Oil --float ' .. sessdir)
    --   end,
    --   desc = '📌manage sessions',
    -- },
    {
      '<leader>sn',
      function()
        require('nvim-possession').new()
      end,
      desc = '📌create new session',
    },
    {
      '<leader>su',
      function()
        require('nvim-possession').update()
      end,
      desc = '📌update current session',
    },
  },

  config = function()
    local possession = require('nvim-possession')

    possession.setup({
      session_dir = ((vim.fn.stdpath('data')) .. '\\possession\\'),
      autoload = false,
      autosave = false, -- don't automatically save session on quit of nvim
      autoswitch = { -- don't save and delete current session when opening a new one
        enable = false,
        exclude_ft = {},
      },
      -- set options for fzf window
      fzf_winopts = {
        width = 0.6,
        height = 0.9,
        preview = {
          vertical = 'down:50%',
        },
      },
      -- set fzf prompt
      sessions = {
        sessions_prompt = 'Load session: ',
      },
    })
  end,
}
