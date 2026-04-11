-- bullets.lua
-- changed from lazy to vim.pack 3-30-26
-- to handle bulleted lists only in markdown and text files

vim.pack.add({ 'src = https://github.com/dkarter/bullets.vim' })

-- ft = { 'markdown', 'text' } - not sure what this is for, but not needed
vim.g.bullets_enabled_file_types = { 'markdown', 'text' }
-- vim.g.bullets_renumber_on_change = 1
vim.g.bullets_outline_levels = { 'ROM', 'ABC', 'num', 'abc', 'rom', 'std-', 'std*', 'std+', 'chk' }
