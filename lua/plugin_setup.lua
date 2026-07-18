--    ╭────────────────────────────╮
--    │      plugin_setup.lua      │
--    ╰────────────────────────────╯

-- Created: 04/29/26
-- Use autocmds to require plugins in order
-- Called by init.lua
-- 04/30/26 added keymaps and aucmds to load on UIEnter
-- 05/20/26 added function to make code clearer
-- 07/09/26 replaced anonymous autocmd callbacks with named functions

-- Make plg_cfg plugin requires simpler
local function req(plugin)
  require('plg_cfg.' .. plugin)
end

require('keymaps')
require('aucmds')
req('snacks')

-- ────────── lazy loading set up all functions ──────────

local function load_ui_plugins()
  req('catppuccin')
  req('statusline')
  req('mini')
  req('blink')
  req('yazi')
  require('file_exclude')
  -- req('mason')
  if Myfn.is_windows() then
    req('bookmarks_win')
  else
    req('bookmarks_linux')
  end
end

--  ─────────────────────────────────────────────

local function load_buffer_plugins()
  req('native-lsp')
  -- req('flash') -- doesn't work with nightly - 07/18/26 - mini instead
  req('hlslens')
  req('nvim-biscuits')
  req('rainbow')
  req('conform')
  req('pretty-comment')
  req('tiny-comment')
end

--  ─────────────────────────────────────────────

local function load_insert_plugins()
  req('my_abbrevs')
end

--  ─────────────────────────────────────────────

local function load_markdown_plugins()
  req('autolist')
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
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  callback = load_buffer_plugins,
})

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
