-- aerial.lua
--
-- Created: 04/24/26

vim.pack.add({ Gh('stevearc/aerial.nvim') })

-- require('aerial').snacks_picker({
--   layout = {
--     preview = false,
--     preset = 'dropdown',
--   },
-- })

require('aerial').setup({})

-- You probably also want to set a keymap to toggle aerial
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
