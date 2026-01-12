-- treesitter.lua
-- code from ChatGPT
-- kept on 'master' instead of 'main' so code-biscuits works

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  build = ':TSUpdate',
  lazy = false,

  config = function()
    local ts = require('nvim-treesitter.configs')

    -- Helper to auto-disable on huge files
    local function too_big(lang, buf)
      local max = 200 * 1024 -- 200 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max then
        return true
      end
      return false
    end

    ts.setup({
      -- Install the parsers you actually use
      ensure_installed = {
        'awk',
        'bash',
        'c',
        'csv',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'toml',
        'vim',
        'vimdoc',
        'powershell',
        'diff',
      },

      auto_install = true,

      highlight = {
        enable = true,
        -- Avoid regex fallback; reduces flicker/dup highlights
        additional_vim_regex_highlighting = {},
        disable = function(lang, buf)
          return too_big(lang, buf)
        end,
      },

      indent = {
        enable = true,
        -- Markdown indent can be quirky
        disable = { 'markdown' },
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          node_decremental = '<BS>',
          scope_incremental = '<TAB>',
        },
      },
    })
  end,
}
