--    ╭────────────────────────────╮
--    │        autolist.lua        │
--    ╰────────────────────────────╯

-- Created: 05/07/26
-- moved from bullet.vim - newer, faster, leaner

vim.pack.add({ Gh('gaoDean/autolist.nvim') })

require('autolist').setup({})

Kset('i', '<tab>', '<cmd>AutolistTab<cr>')
Kset('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>')
-- Kset("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
Kset('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>')
Kset('n', 'o', 'o<cmd>AutolistNewBullet<cr>')
Kset('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>')
-- Kset('n', '<CR>', '<cmd>AutolistToggleCheckbox<cr><CR>')
Kset('n', '<a-r>', '<cmd>AutolistRecalculate<cr>')

-- cycle list types with dot-repeat
Kset('n', '<leader>cn', require('autolist').cycle_next_dr, { expr = true })
Kset('n', '<leader>cp', require('autolist').cycle_prev_dr, { expr = true })

-- functions to recalculate list on edit
Kset('n', '>>', '>><cmd>AutolistRecalculate<cr>')
Kset('n', '<<', '<<<cmd>AutolistRecalculate<cr>')
Kset('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>')
Kset('v', 'd', 'd<cmd>AutolistRecalculate<cr>')
