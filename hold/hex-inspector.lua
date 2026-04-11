-- hex-inspector.lua
-- changed from lazy to vim.pack 3-30-26
--
-- Created: 02/27/26

vim.pack.add({ 'https://github.com/Punity122333/hexinspector.nvim' })

cmd = { 'HexEdit', 'HexInspect' }

vim.keymap.set('n', '<leader>zx', function()
  require('hexinspector').open()
end, { desc = 'Hex Editor' })

vim.keymap.set('n', '<leader>zX', function()
  vim.ui.input({ prompt = 'File path: ', default = vim.fn.expand('%:p') }, function(input)
    if input and input ~= '' then
      require('hexinspector').open(input)
    end
  end)
end, { desc = 'Hex Editor (Pick File)' })
