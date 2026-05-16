--    ╭────────────────────────────╮
--    │     nvim-lspconfig.lua     │
--    ╰────────────────────────────╯

vim.pack.add({
  Gh('neovim/nvim-lspconfig'),
  -- { src = Gh('folke/lazydev.nvim'), data = { ft = 'lua' } },
})

-- Provide :LspInfo even if nvim-lspconfig doesn't define it yet.
if vim.fn.exists(':LspInfo') == 0 then
  vim.api.nvim_create_user_command('LspInfo', function()
    vim.cmd('checkhealth vim.lsp')
  end, { desc = 'Alias for :checkhealth vim.lsp' })
end

-- =============================================================================
-- BLINK CAPABILITY PROXY
-- =============================================================================
-- We check if blink is loaded. If not, we use a basic table so we don't crash.
-- Once you enter Insert Mode (triggering your lazy-load), blink handles the rest.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- server configurations
local servers = {
  lua_ls = {
    bashls = {
      cmd = { 'bash-language-server', 'start' },
      settings = { bashIde = { globPattern = '**/*@(.sh|.inc|.bash|.command)' } },
    },
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        diagnostics = {
          globals = { 'Snacks', 'Status', 'cx', 'ui', 'ya', 'vim', 'MiniFiles' },
        },
        telemetry = { enable = false },
        workspace = { checkThirdParty = false },
      },
    },
  },
  marksman = { filetypes = { 'markdown' } },
  taplo = {},
  vimls = {},
}

for name, conf in pairs(servers) do
  local final_config = vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, conf)

  vim.lsp.config(name, final_config)

  local bin = (conf.cmd and conf.cmd[1]) or name
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

-- Diagnostic UI Customization
-- stylua: ignore 
vim.diagnostic.config({
  float            = { border  = 'rounded' }, -- Matches your aesthetic
  severity_sort    = true,
  underline        = true,
  update_in_insert = false,
  virtual_text     = { spacing = 4, prefix = '●' },
})
