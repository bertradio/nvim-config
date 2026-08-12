--    ╭────────────────────────────╮
--    │        native-lsp.lua      │
--    ╰────────────────────────────╯

-- Created: 06/22/26
-- Optimized for Neovim 0.13+ (Zero external dependencies for configs)
-- Code from Gemini to replace nvim-lspconfig

--   Gh('folke/lazydev.nvim'),
-- })
--
-- require('lazydev').setup()

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
          globals = { 'Status', 'cx', 'ui', 'ya', 'vim', '_G.Kset', '_G.Myfn', '_G.Gh' },
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
  vim.lsp.config(name, conf)
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
