--    ╭────────────────────────────╮
--    │         flash.lua          │
--    ╰────────────────────────────╯

-- modified 05/06/26 for lighter backdrop - replaced mini.jump and jump2

-- vim.pack.add({ Gh('folke/flash.nvim') })

vim.pack.add({
  {
    src = 'https://github.com/pedro757/flash.nvim.git',
    version = 'fix/neovim-0.13-search-state',
    name = 'flash.nvim',
  },
})

local flash = require('flash')

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

flash.setup({

  jumplist = true,
  -- add pattern to search history
  history = true,
  -- clear highlight after jump
  nohlsearch = false,

  modes = {
    search = { enabled = false },
    char = { jump_labels = true },
  },
})

Kset({ 'n', 'x', 'o' }, 's', function()
  flash.jump()
end, { desc = 'Flash' })

Kset({ 'n', 'x', 'o' }, 'S', function()
  flash.treesitter()
end, { desc = 'Flash Treesitter' })

Kset({ 'o', 'x' }, 'R', function()
  flash.treesitter_search()
end, { desc = 'Treesitter Search' })

Kset('o', 'r', function()
  flash.remote()
end, { desc = 'Remote Flash' })

-- -- Kset('c', '<c-s>', function()
-- --   flash.toggle()
-- -- end, { desc = 'Toggle Flash Search' })
