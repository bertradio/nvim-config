--    ╭────────────────────────────╮
--    │      plugin_setup.lua      │
--    ╰────────────────────────────╯

-- Created: 04/29/26
-- use audtocmds to require plugins in order
-- called by init.lua
-- 04/30/26 added keymaps and aucmds to load on UIEnter
-- 05/20/26 added function to make code clearer

-- function to make plg_cfg plugin requires simpler
local function req(plug)
  local pl = 'plg_cfg.' .. plug
  require(pl)
end

--  ────────── lazy loading ──────────

-- load when UI starts - sets load order
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    -- 1. Load the Theme and Layout structures first
    req('catppuccin')
    req('which-key') -- Load WK early so it captures everything following it
    require('keymaps') -- Load global core maps
    -- 2. Load the Statuslines / UI wrappers
    req('lualine')
    req('dressing')
    req('noice')
    -- 3. Load the heavy toolchains (they will instantly hook into WK)
    req('snacks')
    req('blink-spell')
    -- 4 Others
    require('aucmds')
    req('yazi')
    req('mason')
    req('pack-ui')
    if Myfn.is_windows() then
      req('bookmarks_win')
    else
      req('bookmarks_linux')
    end
  end,
})

-- load on entering first buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = function()
    req('mini')
    req('arborist')
    req('flash')
    req('nvim-biscuits')
    req('rainbow')
    req('conform')
    req('pretty-comment')
    req('tiny-comment')
    req('native-lsp')
    -- req('quicker')
  end,
})

--load on first enter into insert mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  once = true,
  callback = function()
    req('my_abbrevs')
  end,
})

-- load only for markdown buffers
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  pattern = '*.md',
  callback = function()
    req('autolist')
    req('render-markdown')
  end,
})
