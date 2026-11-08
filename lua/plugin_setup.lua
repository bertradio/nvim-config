--    ╭────────────────────────────╮
--    │      plugin_setup.lua      │
--    ╰────────────────────────────╯

-- Created: 04/29/26
-- Use autocmds to require plugins in order
-- Called by init.lua
-- 04/30/26 added keymaps and aucmds to load on UIEnter
-- 05/20/26 added function to make code clearer
-- 07/09/26 replaced anonymous autocmd callbacks with named functions
-- 08/01/26 split mini into separate files - treating each as a plugin
-- 11/05/26 - modified to use mini.misc.safely

-- load safely with error message
Safereq('keymaps')
Safereq('aucmds')

-- Helper to make plg_cfg plugin requires simpler
local function req(plugin)
  Safereq('plg_cfg.' .. plugin)
end

-- Snacks must register its startup handlers before files are opened.
req('snacks')

-- ────────── lazy loading set up all functions ──────────
local misc = require('mini.misc')

-- initial loads on UI
misc.safely('event:UIEnter', function()
  req('statusline')
  req('noice')
  req('blink')
  req('which-key')
  req('mason')
  req('native-lsp')
  req('yazi')
  req('colorful-winsep')
  req('bookmarks_linux')
end)

--  ─────────────────────────────────────────────

-- pn enter/new buffer
misc.safely('event:BufReadPre,BufNewFile,BufReadPost', function()
  req('nvim-biscuits')
  req('hlslens')
  req('rainbow')
  req('conform')
  req('flash')
  req('mini-ai')
  req('mini-diff')
  req('mini-move')
  req('mini-surround')
  req('quicker')
  req('undotree')
end)

--  ─────────────────────────────────────────────

-- on first insert
misc.safely('event:InsertEnter', function()
  req('mini-pairs')
  req('my_abbrevs')
  require('my_snippets').setup()
end)

--  ─────────────────────────────────────────────

misc.safely('filetype:markdown', function()
  req('render-markdown')
  req('markdown-plus')
end)

--  ────────────────────────────────────────────────────────
