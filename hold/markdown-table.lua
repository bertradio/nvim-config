--    ╭────────────────────────────╮
--    │     markdown-table.lua     │
--    ╰────────────────────────────╯

--
-- Created: 04/26/26

-- To edit markdown tables
vim.pack.add({ Gh('Kicamon/markdown-table-mode.nvim') })

require('markdown-table-mode').setup({
  filetype = {
    '*.md',
  },
  options = {
    insert = true, -- when typing "|"
    insert_leave = true, -- when leaving insert
    pad_separator_line = false, -- add space in separator line
    alig_style = 'default', -- default, left, center, right
  },
})
