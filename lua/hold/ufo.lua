return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async', -- Required
    'nvim-treesitter/nvim-treesitter', -- Optional but recommended
  },
  event = 'BufReadPost', -- Lazy-load when a file is opened

  config = function()
    vim.o.foldcolumn = '1' -- Show fold column (1 character wide)
    vim.o.foldlevel = 99 -- Open most folds by default
    vim.o.foldlevelstart = 99 -- Same here
    vim.o.foldenable = true -- Enable folding
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
    vim.keymap.set('n', 'K', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        -- choose one of coc.nvim and nvim lsp
        vim.fn.CocActionAsync('definitionHover') -- coc.nvim
        vim.lsp.buf.hover()
      end
    end)
    require('ufo').setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { 'lsp', 'indent' }
      end,
    })
  end,
}
