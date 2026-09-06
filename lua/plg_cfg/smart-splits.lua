-- smart-splits.lua

-- Created: 09/02/26

vim.pack.add({ Gh('mrjones2014/smart-splits.nvim') })

-- recommended mappings
-- resizing splits
-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
Kset('n', '<A-h>', require('smart-splits').resize_left)
Kset('n', '<A-j>', require('smart-splits').resize_down)
Kset('n', '<A-k>', require('smart-splits').resize_up)
Kset('n', '<A-l>', require('smart-splits').resize_right)
-- moving between splits
Kset('n', '<C-h>', require('smart-splits').move_cursor_left)
Kset('n', '<C-j>', require('smart-splits').move_cursor_down)
Kset('n', '<C-k>', require('smart-splits').move_cursor_up)
Kset('n', '<C-l>', require('smart-splits').move_cursor_right)
Kset('n', '<C-\\>', require('smart-splits').move_cursor_previous)
-- swapping buffers between windows
-- Kset('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
-- Kset('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
-- Kset('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
-- Kset('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
