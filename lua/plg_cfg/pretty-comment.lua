--    ╭────────────────────────────╮
--    │     pretty-comment.lua     │
--    ╰────────────────────────────╯

-- various shortcuts for nice comments
-- Created: 04/14/26

vim.pack.add({ Gh('Cartoone9/pretty-comment.nvim') })

require('pretty-comment').setup({
  default_width = 50,
})

--  ────── Recommended keybinds ──────

Kset('v', 'gcb', ':CommentBox<CR>', { silent = true, desc = 'Comment box' })
Kset('n', 'gcb', '<cmd>CommentBox<CR>', { silent = true, desc = 'Comment box (line)' })
Kset('v', 'gcB', ':CommentBoxFat<CR>', { silent = true, desc = 'Fat comment box' })
Kset('n', 'gcB', '<cmd>CommentBoxFat<CR>', { silent = true, desc = 'Fat comment box (line)' })
Kset('v', 'gcl', ':CommentLine<CR>', { silent = true, desc = 'Centered title line' })
Kset('n', 'gcl', '<cmd>CommentLine<CR>', { silent = true, desc = 'Centered title line (line)' })
Kset('v', 'gcL', ':CommentLineFat<CR>', { silent = true, desc = 'Fat centered title line' })
Kset(
  'n',
  'gcL',
  '<cmd>CommentLineFat<CR>',
  { silent = true, desc = 'Fat centered title line (line)' }
)
Kset('n', 'gcs', '<cmd>CommentSep<CR>', { silent = true, desc = 'Comment separator' })
Kset('n', 'gcS', '<cmd>CommentSepFat<CR>', { silent = true, desc = 'Fat comment separator' })
Kset('n', 'gcd', '<cmd>CommentDiv<CR>', { silent = true, desc = 'Comment divider' })
Kset('n', 'gcD', '<cmd>CommentDivFat<CR>', { silent = true, desc = 'Fat comment divider' })
Kset('v', 'gcr', ':CommentRemove<CR>', { silent = true, desc = 'Strip comment decoration' })
Kset(
  'n',
  'gcr',
  '<cmd>CommentRemove<CR>',
  { silent = true, desc = 'Strip comment decoration (line)' }
)
Kset(
  'v',
  'gce',
  ':CommentEqualize<CR>',
  { silent = true, desc = 'Equalize comment decoration (selection)' }
)
Kset(
  'n',
  'gce',
  '<cmd>CommentEqualize<CR>',
  { silent = true, desc = 'Equalize all comment decoration' }
)
Kset('n', 'gcx', '<cmd>CommentReset<CR>', { silent = true, desc = 'Reset comment width tracking' })

--    ╭───────────────────────────────────────────────────────────────────────────────╮
--    │    gc* keybinds above add a delay to visual 'gc' comment toggle. Use 'gcc'    │
--    │                 in visual mode to toggle comments instantly.                  │
--    ╰───────────────────────────────────────────────────────────────────────────────╯

Kset('x', 'gcc', function()
  return require('vim._comment').operator()
end, { expr = true, desc = 'Comment toggle (instant, avoids gc delay)' })
