--    ╭────────────────────────────╮
--    │        pack-ui.lua         │
--    ╰────────────────────────────╯

-- Created: 07/07/26

vim.pack.add({ { src = 'https://github.com/jtprogru/pack-ui.nvim' } })

require('pack_ui').setup({
  border = 'rounded', -- any nvim_open_win border
  title = ' vim.pack ',
  max_width = 100,
  width_ratio = 0.9,
  height_ratio = 0.85,
  auto_check = false, -- on setup, check remotes and notify if updates exist
  auto_update = false, -- on setup, apply every available update automatically
  -- default keymaps
  keymaps = {
    prefix = '<leader>p',
    status = 's', -- <leader>ps -> :PackStatus
    update_all = 'U', -- <leader>pU -> :PackUpdateAll
  },
})

Kset('n', '<Leader>pu', '<cmd>PackUpdate<cr>', { desc = 'pack-ui: update' })
