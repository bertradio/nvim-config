-- surround.lua
--
-- Created: 09/18/25

return {
  require('mini.surround').setup({
    mappings = {
      add = 'gza', -- Add surround
      delete = 'gzd', -- Delete surround
      replace = 'gzr', -- Replace surround
      find = 'gzf', -- Find to the right
      find_left = 'gzF', -- Find to the left
      highlight = 'gzh', -- Highlight surrounding
      update_n_lines = 'gzn', -- Update n_lines
    },
    n_lines = 50, -- search window for surroundings
  }),
}
