-- conform.lua
-- Created: 2023-12-17
-- Sync-safe across Linux & Windows (Syncthing). No Myfn dependency.
-- code re-written by Gemini to simplify with new treesitter

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<Leader>p',
      function()
        require('conform').format({ lsp_format = 'fallback', timeout_ms = 1500 })
      end,
      mode = { 'n', 'v' },
      desc = 'Make pretty with Conform',
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettierd', stop_after_first = true },
      -- typescript = { 'prettier', stop_after_first = true },
      markdown = { 'prettierd' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      toml = { 'taplo' },
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
  },
}
