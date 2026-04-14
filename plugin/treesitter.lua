--    ╭────────────────────────────╮
--    │       treesitter.lua       │
--    ╰────────────────────────────╯

-- changed from lazy to -- vim.pack 3-30-26
-- Re-write for new main branch of treesitter
-- code from Gemini 12/30/25

-- suggested in docs
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  { src = Gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
})

local ts = require('nvim-treesitter')

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
