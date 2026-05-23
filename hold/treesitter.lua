--    ╭────────────────────────────╮
--    │       treesitter.lua       │
--    ╰────────────────────────────╯

-- Updated by Perplexity 4-23-26: Fixed TSUpdate typo, improved PackChanged autocmd,
--                  added incremental_selection + indent modules,
--                  raised file size threshold, added luadoc grammar,
--                  wrapped setup in vim.schedule for safety.

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      -- Schedule to avoid blocking the event loop during an update
      vim.schedule(function()
        vim.cmd('TSUpdate')
      end)
    end
  end,
})

vim.pack.add({
  { src = Gh('nvim-treesitter/nvim-treesitter'), version = 'main', build = ':TSUpdate' },
})

local ts = require('nvim-treesitter')

-- Wrapped in vim.schedule to avoid potential race with parser availability
-- on the main branch when loading at pack time
vim.schedule(function()
  ts.setup({
    ensure_installed = {
      'awk',
      'bash',
      'c',
      'csv',
      'diff',
      'json',
      'lua',
      'luadoc', -- adds grammar for ---@param annotation comments
      'markdown',
      'markdown_inline',
      'powershell',
      'python',
      'query',
      'toml',
      'vim',
      'vimdoc',
    },

    auto_install = true,

    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 500 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },

    -- Allows expanding/shrinking selections by treesitter node boundaries
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        node_decremental = '<bs>',
      },
    },

    -- Treesitter-based indentation; particularly useful for Lua and Python
    indent = { enable = true },
  })
end)
