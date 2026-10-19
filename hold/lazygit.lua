--    ╭────────────────────────────╮
--    │        lazygit.lua         │
--    ╰────────────────────────────╯

-- changed from lazy to -- vim.pack 3-30-26
--
-- Created: 01/17/26

vim.pack.add({ 'https://github.com/nvim-lua/plenary.nvim' })
vim.pack.add({ 'https://github.com/kdheepak/lazygit.nvim' })

cmd = {
  'LazyGit',
  'LazyGitConfig',
  'LazyGitCurrentFile',
  'LazyGitFilter',
  'LazyGitFilterCurrentFile',
}

vim.keymap.set('n', '<Leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
