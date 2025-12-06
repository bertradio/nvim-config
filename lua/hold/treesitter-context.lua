-- treesitter-context.lua

-- Created: 01/07/24

vim.keymap.set('n', '<leader>a', function()
  require('treesitter-context').toggle()
end, { desc = 'Toggle Treesitter Context' })

vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])

return {

  'nvim-treesitter/nvim-treesitter-context',

  config = function()
    require('treesitter-context').setup({
      max_lines = 3, -- show up to 3 lines of context
      multiline_threshold = 20,
    })
  end,
}
