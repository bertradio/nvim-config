-- treesitter re-write for new main branch of treesitter
-- code from Gemini 12/30/25

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  config = function()
    local ts = require('nvim-treesitter')

    -- 1. Setup the basic configuration
    ts.setup({
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
        disable = function(lang, buf)
          local max_filesize = 200 * 1024 -- 200 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
    })

    -- set in snacks/statuscolumn
    -- 2. Modern Folding (Built into Neovim 0.10+)
    -- vim.o.foldmethod = 'expr'
    -- vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.o.foldenable = false
  end,
}
