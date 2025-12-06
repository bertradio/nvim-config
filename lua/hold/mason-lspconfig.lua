-- lspconfig.lua
--
-- Created: 12/10/23

return {
  'williamboman/mason.nvim',
  -- dependencies = {
  --   'williamboman/mason-lspconfig.nvim',
  --   'neovim/nvim-lspconfig',
  },
  config = function()
    require('mason').setup()
    -- require('mason-lspconfig').setup({
    --   ensure_installed = { 'lua_ls' }, -- This will install lua_ls if it's not present
    --   automatic_installation = true, -- Automatically install servers not found
    -- })
  end,
}
