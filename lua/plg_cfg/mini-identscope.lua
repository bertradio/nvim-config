--    ╭────────────────────────────╮
--    │    mini-identscope.lua     │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

require('mini.indentscope').setup({})

-- set symbol color
vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', {
  -- fg = '#f38ba6', -- red
  fg = '#ffffff', -- white

  nocombine = true,
})
