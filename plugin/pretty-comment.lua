--    ╭────────────────────────────╮
--    │     pretty-comment.lua     │
--    ╰────────────────────────────╯

-- Created: 04/14/26

vim.pack.add({ Gh('/Cartoone9/pretty-comment.nvim') })

require('pretty-comment').setup({
  default_width = 50,
})

--    ╭────────────────────────────────────────────╮
--    │            Recommended keybinds            │
--    ╰────────────────────────────────────────────╯
vim.keymap.set('v', 'gcb', ':CommentBox<CR>', { silent = true, desc = 'Comment box' })
vim.keymap.set('n', 'gcb', '<cmd>CommentBox<CR>', { silent = true, desc = 'Comment box (line)' })
vim.keymap.set('v', 'gcB', ':CommentBoxFat<CR>', { silent = true, desc = 'Fat comment box' })
vim.keymap.set(
  'n',
  'gcB',
  '<cmd>CommentBoxFat<CR>',
  { silent = true, desc = 'Fat comment box (line)' }
)
vim.keymap.set('v', 'gcl', ':CommentLine<CR>', { silent = true, desc = 'Centered title line' })
vim.keymap.set(
  'n',
  'gcl',
  '<cmd>CommentLine<CR>',
  { silent = true, desc = 'Centered title line (line)' }
)
vim.keymap.set(
  'v',
  'gcL',
  ':CommentLineFat<CR>',
  { silent = true, desc = 'Fat centered title line' }
)
vim.keymap.set(
  'n',
  'gcL',
  '<cmd>CommentLineFat<CR>',
  { silent = true, desc = 'Fat centered title line (line)' }
)
vim.keymap.set('n', 'gcs', '<cmd>CommentSep<CR>', { silent = true, desc = 'Comment separator' })
vim.keymap.set(
  'n',
  'gcS',
  '<cmd>CommentSepFat<CR>',
  { silent = true, desc = 'Fat comment separator' }
)
vim.keymap.set('n', 'gcd', '<cmd>CommentDiv<CR>', { silent = true, desc = 'Comment divider' })
vim.keymap.set(
  'n',
  'gcD',
  '<cmd>CommentDivFat<CR>',
  { silent = true, desc = 'Fat comment divider' }
)
vim.keymap.set(
  'v',
  'gcr',
  ':CommentRemove<CR>',
  { silent = true, desc = 'Strip comment decoration' }
)
vim.keymap.set(
  'n',
  'gcr',
  '<cmd>CommentRemove<CR>',
  { silent = true, desc = 'Strip comment decoration (line)' }
)
vim.keymap.set(
  'v',
  'gce',
  ':CommentEqualize<CR>',
  { silent = true, desc = 'Equalize comment decoration (selection)' }
)
vim.keymap.set(
  'n',
  'gce',
  '<cmd>CommentEqualize<CR>',
  { silent = true, desc = 'Equalize all comment decoration' }
)
vim.keymap.set(
  'n',
  'gcx',
  '<cmd>CommentReset<CR>',
  { silent = true, desc = 'Reset comment width tracking' }
)

--    ╭───────────────────────────────────────────────────────────────────────────────╮
--    │    gc* keybinds above add a delay to visual 'gc' comment toggle. Use 'gcc'    │
--    │                 in visual mode to toggle comments instantly.                  │
--    ╰───────────────────────────────────────────────────────────────────────────────╯

vim.keymap.set('x', 'gcc', function()
  return require('vim._comment').operator()
end, { expr = true, desc = 'Comment toggle (instant, avoids gc delay)' })
