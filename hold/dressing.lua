--    ╭────────────────────────────╮
--    │        dressing.lua        │
--    ╰────────────────────────────╯

-- Created: 05/03/26

vim.pack.add({ Gh('stevearc/dressing.nvim') })

-- stylua: ignore 
require('dressing').setup({
  input = {
    enabled        = true,
    default_prompt = '➤ ',
    border         = 'rounded',
    relative       = 'cursor', -- Opens where you are typing
    prefer_width   = 40,
  },
  select = {
    enabled = true,
    backend = { 'builtin', 'fzf_lua' }, -- Tries these in order
    builtin = {
      border = 'rounded',
    },
  },
})
