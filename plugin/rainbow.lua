-- rainbow.lua
-- changed from lazy to -- vim.pack 3-30-26
--
-- Created: 03/09/24
--
-- highlight matching delimiters with different colors

-- vim.pack.add({ { src = 'https://github.com/HiPhish/rainbow-delimiters.nvim' } })

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
