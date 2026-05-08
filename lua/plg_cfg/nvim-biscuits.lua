--    ╭────────────────────────────╮
--    │     nvim-biscuits.lua      │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
--
-- Created: 07/14/25

vim.pack.add({ Gh('code-biscuits/nvim-biscuits') })

-- stylua: ignore 
require('nvim-biscuits').setup({
  default_config = {
    trim_by_words = true,
    max_length    = 4, -- max number of words to display
    min_distance  = 3, -- won't display less than these number of lines
  },
  -- disable for languages
  language_config = {
    markdown = { disabled = true },
    text     = { disabled = true },
  },
})
