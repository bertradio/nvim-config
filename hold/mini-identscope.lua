--    ╭────────────────────────────╮
--    │    mini-identscope.lua     │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

-- exclude filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'csv' },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

require('mini.indentscope').setup({})
