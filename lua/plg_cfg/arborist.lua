--    ╭────────────────────────────╮
--    │        arborist.lua        │
--    ╰────────────────────────────╯

-- Created: 05/22/26
-- replacement for tree-sitter.nvim

vim.pack.add({ Gh('arborist-ts/arborist.nvim'), Gh('arborist-ts/queries') })

require('arborist').setup({
  ensure_installed = {
    'awk',
    'bash',
    'csv',
    'diff',
    'json',
    'luadoc',
    -- 'powershell',
    'python',
    'query',
    'toml',
    'vimdoc',
  },
})
