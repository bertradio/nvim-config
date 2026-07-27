--    ╭────────────────────────────╮
--    │        native-lsp.lua      │
--    ╰────────────────────────────╯

-- Created: 06/22/26
-- Optimized for Neovim 0.13+ (Zero external dependencies for configs)
-- Code from Gemini to replace nvim-lspconfig

-- vim.pack.add({
--   Gh('folke/lazydev.nvim'),
-- })

-- =============================================================================
-- BLINK CAPABILITY PROXY
-- =============================================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- =============================================================================
-- NATIVE SERVER CONFIGURATIONS (v0.13 Core)
-- =============================================================================
-- We now define 'root_markers' explicitly so Core knows when to attach.
local servers = {
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh', 'bash', 'zsh' },
    root_markers = { '.git' },
    settings = { bashIde = { globPattern = '**/*@(.sh|.inc|.bash|.command|.zsh)' } },
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        diagnostics = {
          globals = { 'Snacks', 'Status', 'cx', 'ui', 'ya', 'vim', 'Kset', 'Myfn', 'Gh' },
        },
        telemetry = { enable = false },
        workspace = { checkThirdParty = false },
      },
    },
  },
  marksman = {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown' },
    root_markers = { '.git', '.marksman.toml' },
  },
  taplo = {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_markers = { '.git', 'Cargo.toml' },
  },
  vimls = {
    cmd = { 'vim-language-server', '--stdin' },
    filetypes = { 'vim' },
    root_markers = { '.git' },
  },
}

-- Native loop for Core registration and auto-activation
for name, conf in pairs(servers) do
  -- Merge capabilities and inject filetypes/root_markers into the base config
  local final_config = vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, conf)

  -- Register the configuration schema to core
  vim.lsp.config(name, final_config)

  -- Check if binary is present. If yes, enable auto-starting for matching filetypes
  local bin = conf.cmd[1]
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

-- =============================================================================
-- DIAGNOSTIC UI CUSTOMIZATION
-- =============================================================================
-- stylua: ignore 
vim.diagnostic.config({
  float            = { border  = 'rounded' },
  severity_sort    = true,
  underline        = true,
  update_in_insert = false,
  virtual_text     = { spacing = 4, prefix = '●' },
})
