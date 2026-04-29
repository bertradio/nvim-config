--    ╭───────────────────────────────╮
--    │    tree-sitter-manager.lua    │
--    ╰───────────────────────────────╯

-- Optimized for Neovim 0.12 + Native Package Management
-- Replaced archived nvim-treesitter with tree-sitter-manager.nvim
-- Revisions by Gemini 04/25/26

vim.pack.add({
  Gh('romus204/tree-sitter-manager.nvim'),
})

require('tree-sitter-manager').setup({
  -- C, Lua, Markdown, Vim, and Vimdoc are bundled with 0.12 core;
  -- adding them here is safe but strictly optional.
  ensure_installed = {
    'awk',
    'bash',
    'csv',
    'diff',
    'json',
    'luadoc',
    'powershell',
    'python',
    'query',
    'toml',
    'vimdoc',
  },

  -- Automatically install missing parsers when opening a new filetype
  auto_install = true,

  -- Highlighting is enabled by default in tree-sitter-manager via core APIs
  highlight = true,
})

-- 1. NATIVE HIGHLIGHTING & INDENTATION
-- In 0.12, we use a simple autocmd to trigger native Treesitter start.
-- This replaces the complex highlight/indent modules from the old plugin.
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Skip for large files (re-implementing your 500KB threshold)
    local max_filesize = 500 * 1024
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      return
    end

    pcall(vim.treesitter.start)
    -- Enable native folding if desired
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})

-- 2. NATIVE INCREMENTAL SELECTION
-- 0.12 includes native keymaps: 'v an' (outer) and 'v in' (inner).
vim.keymap.set('x', '<C-space>', 'an', { remap = true, desc = 'Increment selection (Native)' })
vim.keymap.set('x', '<BS>', 'in', { remap = true, desc = 'Decrement selection (Native)' })
