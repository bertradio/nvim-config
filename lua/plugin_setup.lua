--    ╭────────────────────────────╮
--    │      plugin_setup.lua      │
--    ╰────────────────────────────╯

-- Created: 04/29/26
-- use audtocmds to require plugins in order
-- called by init.lua
-- 04/30/26 added keymaps and aucmds to load on UIEnter

--  ────────── lazy loading ──────────

-- load when UI starts - sets load order
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    -- 1. Load the Theme and Layout structures first
    require('plg_cfg.catppuccin')
    require('plg_cfg.which-key') -- Load WK early so it captures everything following it
    require('keymaps') -- Load global core maps
    -- 2. Load the Statuslines / UI wrappers
    require('plg_cfg.mini')
    require('plg_cfg.lualine')
    require('plg_cfg.dressing')
    -- 3. Load the heavy toolchains (they will instantly hook into WK)
    require('plg_cfg.nvim-lspconfig')
    require('plg_cfg.fzf-lua')
    require('plg_cfg.snacks')
    -- 4 Others
    require('plg_cfg.tree-sitter-manager')
    require('plg_cfg.blink-spell')
    require('aucmds')
    require('plg_cfg.mason')
    require('plg_cfg.yazi')
    if Myfn.is_windows() then
      require('plg_cfg.bookmarks_win')
    else
      require('plg_cfg.bookmarks_linux')
    end
  end,
})

-- load on entering first buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = function()
    require('plg_cfg.nvim-biscuits')
    require('plg_cfg.rainbow')
    require('plg_cfg.conform')
    require('plg_cfg.pretty-comment')
    require('plg_cfg.winsep')
  end,
})

--load on first enter into insert mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  once = true,
  callback = function()
    require('plg_cfg.flash')
    require('plg_cfg.my_abbrevs')
  end,
})

-- load only for markdown buffers
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  pattern = '*.md',
  callback = function()
    require('plg_cfg.bullets')
  end,
})
