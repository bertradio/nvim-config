--    ╭────────────────────────────╮
--    │        bullets.lua         │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- to handle bulleted lists only in markdown and text files
-- 05/08/26 - experimented with autolist and markdown=plus
-- even though bullets is old and in vimscript
-- still works best for my needs - solid!

vim.pack.add({ Gh('dkarter/bullets.vim') })

vim.g.bullets_enabled_file_types = { 'markdown', 'text', 'txt' }

vim.g.bullets_outline_levels = { 'ROM', 'ABC', 'num', 'abc', 'rom', 'std-', 'std*', 'std+', 'chk' }

Kset('n', '<Leader>r', 'gN', { desc = 'Renumber markdown list' })
