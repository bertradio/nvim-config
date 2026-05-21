--    ╭────────────────────────────╮
--    │        conform.lua         │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Created: 2023-12-17
-- Sync-safe across Linux & Windows (Syncthing). No Myfn dependency.
-- code re-written by Gemini to simplify with new treesitter

vim.pack.add({ Gh('stevearc/conform.nvim') })

local conform = require('conform')

-- stylua: ignore 
conform.setup({
  formatters_by_ft = {
    lua        = { 'stylua' },
    javascript = { 'prettierd', stop_after_first = true },
    json      =  { 'prettierd'},
    markdown   = { 'prettierd' },
    sh         = { 'shfmt' },
    bash       = { 'shfmt' },
    toml       = { 'taplo' },
  },
  format_on_save = {
    lsp_format = 'fallback',
    timeout_ms = 1500,
  },
  formatters = {
    shfmt = {
      prepend_args = { '-i', '2' },
    },
  },
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    Kset({ 'n', 'v' }, '<leader>p', function()
      conform.format({ lsp_format = 'fallback', timeout_ms = 1500 })
    end, { desc = 'Make pretty with Conform' })
  end,
})
