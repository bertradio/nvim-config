--    ╭────────────────────────────╮
--    │     nvim-lspconfig.lua     │
--    ╰────────────────────────────╯

-- Neovim 0.12-style LSP setup
-- Updated 3-31-26: Fixed LSP snippet negotiation for blink.cmp

vim.pack.add({
  Gh('neovim/nvim-lspconfig'),
  Gh('saghen/blink.cmp'),
  -- lazydev handles the "vim" global and workspace library discovery efficiently
  { src = Gh('folke/lazydev.nvim'), data = { ft = 'lua' } },
})

-- Provide :LspInfo even if nvim-lspconfig doesn't define it yet.
if vim.fn.exists(':LspInfo') == 0 then
  vim.api.nvim_create_user_command('LspInfo', function()
    vim.cmd('checkhealth vim.lsp')
  end, { desc = 'Alias for :checkhealth vim.lsp' })
end

-- IMPORTANT: This must be called AFTER blink.cmp is added to vim.pack
local capabilities = require('blink.cmp').get_lsp_capabilities()

local servers = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace', -- Improves snippet behavior for function calls
        },
        diagnostics = {
          -- globals removed here because lazydev.nvim (above) handles them automatically
          globals = { 'Snacks', 'Status', 'cx', 'ui', 'ya', 'vim' },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  marksman = {
    filetypes = { 'markdown' },
  },

  taplo = {},

  vimls = {},

  bashls = {
    cmd = { 'bash-language-server', 'start' },
    -- This forces the LSP to look for the system's bash path
    settings = {
      bashIde = {
        globPattern = '**/*@(.sh|.inc|.bash|.command)',
      },
    },
  },
}

-- Loop through servers and enable them with blink capabilities
for name, conf in pairs(servers) do
  -- Merge your specific server config with the blink capabilities
  local final_config = vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, conf)

  -- Use 0.12 native LSP configuration
  vim.lsp.config(name, final_config)

  -- Check if binary exists before enabling to avoid startup errors
  local bin = (conf.cmd and conf.cmd[1]) or name
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

-- Diagnostic UI Customization
-- stylua: ignore 
vim.diagnostic.config({
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border  = 'rounded' },
  virtual_text     = { spacing = 4, prefix = '●' },
})
