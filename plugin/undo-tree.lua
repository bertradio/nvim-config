-- undotree.lua

-- activate built-in for nvim 0.12

vim.cmd('packadd nvim.undotree')
vim.keymap.set('n', '<leader>u', require('undotree').open, { desc = 'undotree' })
