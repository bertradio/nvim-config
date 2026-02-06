-- nvim-lspconfig.lua (Optimized for v0.11.x)
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
  },
  event = { 'BufReadPre', 'BufNewFile' },

  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- 1. Define Servers
    local servers = {
      lua_ls = {
        -- On Linux Mint, the binary is usually named exactly this:
        cmd = { 'lua-language-server' },
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim', 'Snacks', 'Status', 'cx', 'ui', 'ya' } },
            workspace = { checkThirdParty = false },
          },
        },
      },
      marksman = {
        -- Explicitly setting this stops the "mdx" warning in checkhealth
        filetypes = { 'markdown' },
      },
      taplo = {},
      vimls = {},
      bashls = {
        filetypes = { 'sh', 'zsh', 'bash' },
        -- Ensure it picks up zsh properly
        settings = { bashIde = { shellbeers = 'bash' } },
      },
    }

    -- 2. Apply using Native v0.11 API
    for name, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})

      -- Set the configuration
      vim.lsp.config(name, config)

      -- Crucial: Check if the binary exists before enabling
      -- If 'cmd' isn't defined, it defaults to the server name
      local bin = (config.cmd and config.cmd[1]) or name
      if vim.fn.executable(bin) == 1 then
        vim.lsp.enable(name)
      end
    end

    -- 3. Diagnostic Styling
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = 'rounded' },
    })
  end,
}
