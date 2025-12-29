-- conform.lua
-- Created: 2023-12-17
-- Sync-safe across Linux & Windows (Syncthing). No Myfn dependency.
-- code re-written by Gemini

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
  opts = function()
    -- Helper for cross-OS executables
    local function choose_cmd(candidates)
      for _, cmd in ipairs(candidates) do
        if vim.fn.executable(cmd) == 1 then
          return cmd
        end
      end
      return candidates[1]
    end

    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

    -- Commands
    local prettier_cmd =
      choose_cmd(is_windows and { 'prettierd.cmd', 'prettier.cmd' } or { 'prettierd', 'prettier' })
    local stylua_cmd = choose_cmd(is_windows and { 'stylua.exe', 'stylua' } or { 'stylua' })
    local shfmt_cmd = choose_cmd(is_windows and { 'shfmt.exe', 'shfmt' } or { 'shfmt' })

    return {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        markdown = { 'prettier' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
      },
      format_on_save = {
        lsp_format = 'fallback',
        timeout_ms = 1500,
      },
      formatters = {
        prettier = { inherit = true, command = prettier_cmd },
        stylua = { inherit = true, command = stylua_cmd },
        shfmt = {
          inherit = true,
          command = shfmt_cmd,
          prepend_args = { '-i', '2' },
        },
      },
    }
  end,
}
