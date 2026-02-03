-- seeker.lua
--
-- Created: 01/23/26

return {
  '2kabhishek/seeker.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cmd = { 'Seeker' },
  keys = {
    { '<leader>sf', ':Seeker files<CR>', desc = 'Seek Files' },
    { '<leader>ss', ':Seeker git_files<CR>', desc = 'Seek Git Files' },
    { '<leader>sg', ':Seeker grep<CR>', desc = 'Seek Grep' },
  },
  opts = {}, -- Required unless you call seeker.setup() manually, add your configs here
}
