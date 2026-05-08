--    ╭────────────────────────────╮
--    │         flash.lua          │
--    ╰────────────────────────────╯

-- modified 05/06/26 for lighter backdrop - replaced mini.jump and jump2

vim.pack.add({ Gh('folke/flash.nvim') })

-- set hl groups for flash
vim.api.nvim_set_hl(0, 'FlashBackdrop', {
  fg = '#ACACAC', -- lighter/dimmer adjustment
})

vim.api.nvim_set_hl(0, 'FlashMatch', {
  fg = '#1e1e2e',
  bg = '#f9e2af',
  bold = true,
})

vim.api.nvim_set_hl(0, 'FlashCurrent', {
  fg = '#1e1e2e',
  bg = '#fab387',
  bold = true,
})

require('flash').setup({
  jump = {
    -- automatically jump when there is only one match
    autojump = true,
    -- save location in the jumplist
    jumplist = true,
    -- add pattern to search history
    history = true,
    -- clear highlight after jump
    nohlsearch = true,
  },

  modes = {
    search = { enabled = false },
    char = { jump_labels = true },
  },
})

local flash = require('flash')

Kset({ 'n', 'x', 'o' }, 's', function()
  flash.jump({
    search = {
      mode = function(str)
        return '\\<' .. str
      end,
    },
  })
end, { desc = 'Flash - start of word' })

Kset({ 'n', 'x', 'o' }, 'S', function()
  flash.treesitter()
end, { desc = 'Flash Treesitter' })

Kset({ 'o', 'x' }, 'R', function()
  flash.treesitter_search()
end, { desc = 'Treesitter Search' })

Kset('o', 'r', function()
  flash.remote()
end, { desc = 'Remote Flash' })

Kset('c', '<C-s>', function()
  flash.toggle()
end, { desc = 'Toggle Flash Search' })
