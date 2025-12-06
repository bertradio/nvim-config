-- bufclose.lua
--
-- Created: 03/30/25

-- BufClose or Bc: Close the current buffer
-- BufCloseAll or Bca: Close all open buffers
-- BufCloseOther or Bco: Close all open buffers except the current one
-- BufCloseRight or Bcr: Close all open buffers to the right of the current one
-- BufCloseLeft or Bcl: Close all open buffers to the left of the current one

Myfn.map('n', '<Leader>bd', '<cmd>BufClose<cr>', { desc = 'delete buffer' })
--.map('n', '<Leader>ba', '<cmd>BufCloseAll<cr>', { desc = 'close all' })
Myfn.map('n', '<Leader>bo', '<cmd>BufCloseOther<cr>', { desc = 'close other' })

return {
  { 'atomicptr/BufClose.nvim', lazy = false },
}
