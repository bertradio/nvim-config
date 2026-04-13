-- toggler.lua
--
-- Created: 04/12/26

vim.pack.add({ Gh('nguyenvukhang/nvim-toggler') })

vim.keymap.set({ 'n', 'v' }, '<leader>T', require('nvim-toggler').toggle)

require('nvim-toggler').setup({
  remove_default_keybinds = true,
})
