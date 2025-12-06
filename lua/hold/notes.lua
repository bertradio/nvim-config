-- notes.lua
--
-- to take notes in markdown
--
-- Created: 02/10/24

return {
  'dhananjaylatkar/notes.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  keys = {
    { '<Leader>nn', '<cmd>NotesNew<cr>', desc = 'New note' },
    { '<Leader>nf', '<cmd>NotesFind<cr>', desc = 'Find note' },
    { '<Leader>ng', '<cmd>NotesGrep<cr>', desc = 'Grep notes' },
  },

  config = function()
    require('notes').setup({
      -- notes root dir
      root = 'C:\\Users\\bertk\\Home\\Temp\\Notes\\',
      picker = 'telescope',
    })
  end,
}
