-- lazygit.lua
--
-- Created: 01/17/26

vim.pack.add({ 'https://github.com/nvim-lua/plenary.nvim' })
vim.pack.add({ 'https://github.com/kdheepak/lazygit.nvim' })

cmd =
  {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  }, 
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
