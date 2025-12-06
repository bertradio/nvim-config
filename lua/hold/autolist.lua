-- autolist.lua
-- to permit changing of type of list with shortcuts
-- see keymaps below

return {
  'gaoDean/autolist.nvim',
  lazy = false,
  ft = {
    'markdown',
    'text',
  },
  config = function()
    require('autolist').setup()

    vim.keymap.set('i', '<tab>', '<cmd>AutolistTab<cr>')
    vim.keymap.set('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>')
    vim.keymap.set('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>')
    vim.keymap.set('n', 'o', 'o<cmd>AutolistNewBullet<cr>')
    vim.keymap.set('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>')
    vim.keymap.set('n', '<CR>', '<cmd>AutolistToggleCheckbox<cr><CR>')
    vim.keymap.set('n', '<C-r>', '<cmd>AutolistRecalculate<cr>')
    -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent

    -- cycle list types with dot-repeat
    vim.keymap.set(
      'n',
      '<leader>cn',
      require('autolist').cycle_next_dr,
      { expr = true, desc = 'Next list type' }
    )
    vim.keymap.set(
      'n',
      '<leader>cp',
      require('autolist').cycle_prev_dr,
      { expr = true, desc = 'Prev list type' }
    )

    -- functions to recalculate list on some kinds of edit
    vim.keymap.set('n', '>>', '>><cmd>AutolistRecalculate<cr>')
    vim.keymap.set('n', '<<', '<<<cmd>AutolistRecalculate<cr>')
    vim.keymap.set('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>')
    vim.keymap.set('v', 'd', 'd<cmd>AutolistRecalculate<cr>')
  end,
}
