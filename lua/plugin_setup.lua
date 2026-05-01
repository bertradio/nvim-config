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
    require('config.catppuccin')
    require('config.nvim-lspconfig')
    require('config.noice')
    require('config.lualine')
    require('config.snacks')
    require('config.oil')
    require('config.winsep')
    require('config.mini')
    require('config.blink-spell')
    require('config.my_abbrevs')
    require('config.tree-sitter-manager')
    require('config.mason')
    require('keymaps')
    require('augroups')
    -- Platform-specific bookmarks
    if Myfn.is_windows() then
      require('config.bookmarks_win')
    else
      require('config.bookmarks_linux')
    end
  end,
})

-- load on entering buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = function()
    require('config.rainbow')
    require('config.pretty-comment')
    require('config.smart-paste')
    require('config.conform')
    require('config.code-biscuits')
  end,
})

--load on enter insert mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  once = true,
  callback = function()
    require('config.nvim-pairs')
  end,
})

-- load only for markdown buffers
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  pattern = '*.md',
  callback = function()
    require('config.markdown')
    require('config.bullets')
  end,
})
