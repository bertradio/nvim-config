--    ╭────────────────────────────╮
--    │        autolist.lua        │
--    ╰────────────────────────────╯

-- Created: 05/07/26
-- moved from bullet.vim - newer, faster, leaner

vim.pack.add({ Gh('gaoDean/autolist.nvim') })

local autolist = require('autolist')

autolist.setup({})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    local opts = { buffer = args.buf }

    Kset('i', '<tab>', '<cmd>AutolistTab<cr>', opts)
    Kset('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>', opts)
    Kset('i', '<c-t>', '<c-t><cmd>AutolistRecalculate<cr>', opts)
    Kset('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>', opts)
    Kset('n', 'o', 'o<cmd>AutolistNewBullet<cr>', opts)
    Kset('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>', opts)
    Kset('n', '<a-r>', '<cmd>AutolistRecalculate<cr>', opts)

    -- Cycle list types with dot-repeat.
    Kset('n', '<leader>cn', autolist.cycle_next_dr, { buffer = args.buf, expr = true })
    Kset('n', '<leader>cp', autolist.cycle_prev_dr, { buffer = args.buf, expr = true })

    -- Recalculate lists after editing them.
    Kset('n', '>>', '<cmd>>>AutolistRecalculate<cr>', opts)
    Kset('n', '<<', '<cmd>AutolistRecalculate<cr>', opts)
    Kset('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>', opts)
    Kset('v', 'd', 'd<cmd>AutolistRecalculate<cr>', opts)
  end,
})
