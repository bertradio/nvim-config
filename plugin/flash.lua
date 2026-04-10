-- flash.lua
-- changed from lazy to vim.pack 3-30-26
-- Created: 10/27/25

vim.pack.add({ { src = 'https://github.com/folke/flash.nvim' } })

require('flash').setup({
  jump = { autojump = true },
  modes = {
    search = { enabled = false },
    char = { jump_labels = true },
  },
})

vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash' })

vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })

vim.keymap.set('c', '<c-f>', function()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })
