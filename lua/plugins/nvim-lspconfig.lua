-- nvim-lspconfig.lua
-- Neovim 0.12-style LSP setup using:
--   - vim.lsp.config()
--   - vim.lsp.enable()
-- while keeping vim.pack.add() in this file

vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/folke/lazydev.nvim', data = { ft = 'lua' } },
})

-- Provide :LspInfo even if nvim-lspconfig doesn't define it yet.
-- Current nvim-lspconfig documents :LspInfo as an alias to:
--   :checkhealth vim.lsp
if vim.fn.exists(':LspInfo') == 0 then
  vim.api.nvim_create_user_command('LspInfo', function()
    vim.cmd('checkhealth vim.lsp')
  end, { desc = 'Alias for :checkhealth vim.lsp' })
end

local capabilities = require('blink.cmp').get_lsp_capabilities()

local servers = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim', 'Snacks', 'Status', 'cx', 'ui', 'ya' },
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  },

  marksman = {
    filetypes = { 'markdown' },
  },

  taplo = {},

  vimls = {},

  bashls = {
    filetypes = { 'sh', 'bash', 'zsh' },
  },
}

for name, conf in pairs(servers) do
  vim.lsp.config(
    name,
    vim.tbl_deep_extend('force', {
      capabilities = capabilities,
    }, conf)
  )

  local bin = (conf.cmd and conf.cmd[1]) or name
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded' },
})
