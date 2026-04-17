--    ╭────────────────────────────╮
--    │        toggler.lua         │
--    ╰────────────────────────────╯

-- Created: 04/12/26
-- Toggle true/false, on/off, etc.

vim.pack.add({ Gh('nguyenvukhang/nvim-toggler') })

vim.keymap.set({ 'n', 'v' }, '<leader>T', require('nvim-toggler').toggle, { desc = 'Toggle word' })

require('nvim-toggler').setup({
  remove_default_keybinds = true,

  -- your own inverses - example
  -- inverses = {
  --   ['vim'] = 'emacs'
  -- }
})
