--    ╭────────────────────────────╮
--    │        conform.lua         │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Created: 2023-12-17
-- Sync-safe across Linux & Windows (Syncthing). No Myfn dependency.
-- 07/16/26 - Simplified as per ChatGPT

vim.pack.add({ Gh('stevearc/conform.nvim') })

local conform = require('conform')

-- stylua: ignore 
conform.setup({
  formatters_by_ft = {
    lua  = { 'stylua' },
    sh   = { 'shfmt' },
    bash = { 'shfmt' },
  },

  format_on_save = {
    -- lsp_format = 'never', -- default
    lsp_format = 'fallback', -- fallback to lsp if no other formatter available
    timeout_ms = 1500,
  },

  formatters = {
    shfmt = {
      prepend_args = { '-i', '2' },
    },
  },
})

Kset({ 'n', 'x' }, '<leader>mp', function()
  conform.format({
    lsp_format = 'fallback',
    timeout_ms = 1500,
  })
end, { desc = 'Make pretty with Conform' })
