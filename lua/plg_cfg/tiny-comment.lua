--    ╭────────────────────────────╮
--    │      tiny-comment.lua      │
--    ╰────────────────────────────╯
-- Created: 05/24/26

vim.pack.add({ Gh('so1ve/tiny-comment.nvim') })

require('tiny-comment').setup({
  -- Add these along side mini.comment
  -- adds comment and goes into insert mode
  -- stylua: ignore 
  mappings = {
    below = 'gco', -- insert comment on line below
    above = 'gcO', -- insert commnt on line above`
    eol   = 'gcA', -- insert comment at end of line
  },
})
