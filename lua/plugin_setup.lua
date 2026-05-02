--    ╭────────────────────────────╮
--    │      plugin_setup.lua      │
--    ╰────────────────────────────╯

-- Created: 04/29/26
-- use audtocmds to require plugins in order
-- called by init.lua
-- 04/30/26 added keymaps and augroups to load on UIEnter

--  ────────── lazy loading ──────────

-- from Gemini to speed up load
-- startup 04/28/26 0.13!
-- load when UI starts -sets load order

vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    require('plg_cfg.catppuccin')
    require('plg_cfg.nvim-lspconfig')
    require('plg_cfg.noice')
    require('plg_cfg.lualine')
    require('plg_cfg.snacks')
    require('plg_cfg.oil')
    require('plg_cfg.winsep')
    require('plg_cfg.mini')
    require('plg_cfg.blink-spell')
    require('plg_cfg.my_abbrevs')
    require('plg_cfg.tree-sitter-manager')
    require('plg_cfg.mason')
    require('keymaps')
    require('augroups')
    -- Platform-specific bookmarks
    if Myfn.is_windows() then
      require('plg_cfg.bookmarks_win')
    else
      require('plg_cfg.bookmarks_linux')
    end
  end,
})

-- load on entering buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = function()
    require('plg_cfg.rainbow')
    require('plg_cfg.pretty-comment')
    require('plg_cfg.smart-paste')
    require('plg_cfg.conform')
    require('plg_cfg.code-biscuits')
  end,
})

--load on enter insert mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  once = true,
  callback = function()
    require('plg_cfg.nvim-pairs')
  end,
})

-- load only for markdown buffers
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  pattern = '*.md',
  callback = function()
    require('plg_cfg.markdown')
    require('plg_cfg.bullets')
  end,
})
