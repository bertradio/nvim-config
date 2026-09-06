-- tabulature.lua

-- Created: 08/31/26

vim.pack.add({
  'https://github.com/sakakibara/tablature.nvim',
})

local tab = require('tablature')

local function in_table_or(action, fallback)
  return function()
    if tab.in_table() then
      action()
    elseif fallback then
      fallback()
    end
  end
end

tab.setup({
  filetypes = { 'markdown' },
})

vim.keymap.set('n', '<Leader>tra', function()
  tab.insert_row_below()
end, { desc = 'table: insert row below' })
vim.keymap.set('n', '<Leader>trA', function()
  tab.insert_row_above()
end, { desc = 'table: insert row above' })
vim.keymap.set('n', '<Leader>trd', function()
  tab.delete_row()
end, { desc = 'table: delete row' })
vim.keymap.set('n', '<Leader>tca', function()
  tab.insert_column_right()
end, { desc = 'table: insert col right' })
vim.keymap.set('n', '<Leader>tcA', function()
  tab.insert_column_left()
end, { desc = 'table: insert col left' })
vim.keymap.set('n', '<Leader>tcd', function()
  tab.delete_column()
end, { desc = 'table: delete col' })
