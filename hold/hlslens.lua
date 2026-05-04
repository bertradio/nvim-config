--    ╭────────────────────────────╮
--    │        hlslens.lua         │
--    ╰────────────────────────────╯

-- Created: 05/04/26
-- for ghost text at end of line for search

vim.pack.add({ Gh('kevinhwang91/nvim-hlslens') })

-- 1. Setup the plugin with basic defaults
-- require('hlslens').setup({
--   build_position_cb = function(plist, g_frame, elist, td)
--     require('hlslens.render').set_virt(plist, g_frame, elist, td)
--   end,
-- })

-- 2. Improved Keymaps for n and N
local kopts = { noremap = true, silent = true }

vim.keymap.set('n', 'n', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'n')
  require('hlslens').start()
end, kopts)

vim.keymap.set('n', 'N', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'N')
  require('hlslens').start()
end, kopts)
