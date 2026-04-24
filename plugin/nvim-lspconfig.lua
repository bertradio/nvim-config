--    ╭────────────────────────────╮
--    │     nvim-lspconfig.lua     │
--    ╰────────────────────────────╯

-- Neovim 0.12-style LSP setup
-- Updated by Claude.ai 4-23-26: Applied suggestions (lazydev globals, vimls cmd fix,
--                  marksman cleanup, LspAttach keymaps, diagnostic tuning,
--                  callSnippet disabled to avoid blink double-expansion)

-- surpass Diagnosing workspace lua_ls messages
vim.lsp.handlers['$/progress'] = function() end

vim.pack.add({
  Gh('neovim/nvim-lspconfig'),
  Gh('saghen/blink.cmp'),
  -- lazydev handles the "vim" global and workspace library discovery efficiently
  { src = Gh('folke/lazydev.nvim'), data = { ft = 'lua' } },
})

-- Configure lazydev to handle custom globals instead of lua_ls diagnostics.globals
require('lazydev').setup({
  library = {
    { path = 'snacks.nvim', words = { 'Snacks' } },
    -- Add other third-party globals here as needed, e.g.:
    { path = 'mini.nvim', words = { 'MiniFiles' } },
  },
})

-- Provide :LspInfo even if nvim-lspconfig doesn't define it yet.
if vim.fn.exists(':LspInfo') == 0 then
  vim.api.nvim_create_user_command('LspInfo', function()
    vim.cmd('checkhealth vim.lsp')
  end, { desc = 'Alias for :checkhealth vim.lsp' })
end

-- IMPORTANT: This must be called AFTER blink.cmp is added to vim.pack
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- server configurations
local servers = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        completion = {
          -- Disabled to avoid double-expansion when blink.cmp handles snippets.
          -- Re-enable with 'Replace' if you're not seeing snippet issues.
          callSnippet = 'Disable',
        },
        diagnostics = {
          -- Removed globals list — lazydev.nvim handles vim + third-party globals
          -- above via its library option, scoped to your config files only.
          globals = { 'Status', 'cx', 'ui', 'ya' }, -- keep only non-lazydev globals
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  -- marksman auto-declares markdown filetypes; no need to repeat it here
  marksman = {},

  taplo = {},

  -- binary is 'vim-language-server', not 'vimls' — without cmd the enable
  -- check would silently fail since vim.fn.executable('vimls') returns 0
  vimls = {
    cmd = { 'vim-language-server', '--stdio' },
  },

  bashls = {
    cmd = { 'bash-language-server', 'start' },
    settings = {
      bashIde = {
        globPattern = '**/*@(.sh|.inc|.bash|.command)',
      },
    },
  },
}

-- Loop through servers and enable them with blink capabilities
for name, conf in pairs(servers) do
  local final_config = vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, conf)

  vim.lsp.config(name, final_config)

  -- Check if binary exists before enabling to avoid startup errors
  local bin = (conf.cmd and conf.cmd[1]) or name
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

-- LSP keymaps — attached only when an LSP client connects to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', vim.lsp.buf.definition, 'Go to Definition')
    map('gD', vim.lsp.buf.declaration, 'Go to Declaration')
    map('gr', vim.lsp.buf.references, 'Go to References')
    map('gi', vim.lsp.buf.implementation, 'Go to Implementation')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename Symbol')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('<leader>ds', vim.lsp.buf.document_symbol, 'Document Symbols')
  end,
})

-- Diagnostic UI Customization
-- stylua: ignore
vim.diagnostic.config({
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = 'rounded' },
  -- Only show virtual text for warnings and above — suppresses noisy hints
  virtual_text     = {
    spacing  = 4,
    prefix   = '●',
    severity = { min = vim.diagnostic.severity.WARN },
  },
})
