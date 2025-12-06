-- statuscolumn.lua
--
-- Created: 09/03/25

return {
  'snacks.nvim',
  opts = {
    statuscolumn = {
      left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
      right = { 'fold' }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
      },
      refresh = 50, -- refresh at most every 50ms
    },
  },
}
