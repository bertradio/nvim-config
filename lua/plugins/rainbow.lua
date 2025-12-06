-- rainbow.lua
--
-- Created: 03/09/24
--
-- highlight matching delimiters with different colors

return {

  'HiPhish/rainbow-delimiters.nvim',
  event = { 'BufReadPre', 'BufNewFile' },

  config = function()
    local rainbow_delimiters = require('rainbow-delimiters')

    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      priority = {
        [''] = 110,
        lua = 210,
      },
      highlight = {
        'RainbowDelimiterBlue',
        'RainbowDelimiterCyan',
        'RainbowDelimiterGreen',
        'RainbowDelimiterOrange',
        'RainbowDelimiterRed',
        'RainbowDelimiterViolet',
        'RainbowDelimiterYellow',
      },
    }
  end,
}
