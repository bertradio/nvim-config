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

local misc = require('mini.misc')

-- load safely with error message
misc.safely('now', function()
  require('keymaps')
end)
misc.safely('now', function()
  require('aucmds')
end)

-- Helper to make plg_cfg plugin requires simpler
local function req(plugin)
  require('plg_cfg.' .. plugin)
end

-- ────────── lazy loading set up all functions ──────────

local function load_ui_plugins()
  req('catppuccin')
  req('lualine')
  req('noice')
  req('blink')
  req('mini')
  req('mini-clue')
  req('mini-files')
  req('mini-sessions')
  req('mini-pick')
  req('native-lsp')
  req('snacks') -- should com after noice and mini so it handles notifications
  req('smart-splits')
  req('bookmarks_linux')
  req('render-markdown') -- needs to be here to render snacks notification history
  req('yazi') -- needs to be here to render snacks notification history
end

--  ─────────────────────────────────────────────

local function load_buffer_plugins()
  req('nvim-biscuits')
  req('hlslens')
  req('rainbow')
  req('conform')
  req('flash')
  req('mini-ai')
  req('mini-diff')
  req('mini-move')
  req('mini-operators')
  req('mini-pairs')
  req('mini-surround')
  req('pretty-comment')
  req('quicker')
  req('undotree')
end

--  ─────────────────────────────────────────────

local function load_insert_plugins()
  req('my_abbrevs')
  require('my_snippets').setup()
end

--  ─────────────────────────────────────────────

local function load_markdown_plugins()
  req('markdown-plus')
end

--  ────────────────────────────────────────────────────────

--    ╭──────────────────────────────────────────────────╮
--    │    ───── autocmds to run functions once ─────    │
--    ╰──────────────────────────────────────────────────╯

-- Load when the UI starts; this also sets the load order
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = load_ui_plugins,
})

-- Load when entering the first buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile', 'BufReadPost' }, {
  once = true,
  callback = load_buffer_plugins,
})

-- indent-blankline enters existing windows during setup, which is not allowed
-- from a BufReadPre callback.
-- vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
--   once = true,
--   callback = function()
--     req('indent-blankline')
--   end,
-- })

-- Load on the first entry into Insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = load_insert_plugins,
})

-- Load only for the first Markdown buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  pattern = '*.md',
  callback = load_markdown_plugins,
})

-- vim.api.nvim_create_user_command('Mason', function()
--   req('mason')
--   vim.cmd.Mason()
-- end, {})
