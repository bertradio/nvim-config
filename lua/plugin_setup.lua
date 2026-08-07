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

require('keymaps')
require('aucmds')

-- need to load mini here so modules below will work
vim.pack.add({
  Gh('nvim-mini/mini.nvim'),
  Gh('nvim-tree/nvim-web-devicons'),
})

-- Helper to make plg_cfg plugin requires simpler
local function req(plugin)
  require('plg_cfg.' .. plugin)
end

-- ────────── lazy loading set up all functions ──────────

local function load_ui_plugins()
  req('native-lsp')
  req('catppuccin')
  req('statusline')
  req('mini')
  req('mini-clue')
  req('mini-files')
  req('mini-notify')
  req('mini-pick')
  req('blink')
  if Myfn.is_windows() then
    req('bookmarks_win')
  else
    req('bookmarks_linux')
  end
end

--  ─────────────────────────────────────────────

local function load_buffer_plugins()
  req('nvim-biscuits')
  req('hlslens')
  req('rainbow')
  req('conform')
  req('indent-blankline')
  req('mini-ai')
  req('mini-diff')
  req('mini-identscope')
  req('mini-jumps')
  req('mini-move')
  req('mini-operators')
  req('mini-pairs')
  req('mini-surround')
  req('pretty-comment')
  require('my_snippets').setup() -- snippts from core
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
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile', 'BufReadPost' }, {
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

vim.api.nvim_create_user_command('Mason', function()
  req('mason')
  vim.cmd.Mason()
end, {})
