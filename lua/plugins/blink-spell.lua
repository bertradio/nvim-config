-- blink-spell.lua
-- changed from lazy to vim.pack 3-30-26
-- Keeps your original Blink UI & docs behavior intact.
-- Adds LuaSnip config, curated friendly-snippets, and small Bash/PowerShell snippets.
-- Also preserves your spell gating, cmdline/search completion, and prose autocmds.

-- Dependencies first
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  -- { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/ribru17/blink-cmp-spell' },
  { src = 'https://github.com/L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.1' },
})

-- ── LuaSnip config ────────────────────────────────────────────────────────────
local ls = require('luasnip')
ls.config.setup({
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  enable_autosnippets = false,
  region_check_events = 'CursorMoved,CursorHold,InsertEnter',
  delete_check_events = 'TextChanged,InsertLeave',
})

local vs = require('luasnip.loaders.from_vscode')
pcall(vs.lazy_load, { include = { 'lua', 'markdown', 'shellscript', 'powershell' } })

local user_snips = vim.fn.stdpath('config') .. '/snippets'
if vim.fn.isdirectory(user_snips) == 1 then
  pcall(vs.lazy_load, { paths = { user_snips } })
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('sh', {
  s('shb', {
    t({ '#!/usr/bin/env bash', 'set -euo pipefail', "IFS=$'\\n\\t'", '' }),
    t({ '# ' }),
    i(1, 'script description'),
    t({ '', '', 'main() {', '  ' }),
    i(2, '# TODO'),
    t({ '', '}', '', 'main "$@"' }),
  }),
})
ls.add_snippets('bash', ls.get_snippets('sh'))

ls.add_snippets('ps1', {
  s('param', {
    t({ '[CmdletBinding()]', 'param(', '    ' }),
    i(1, '[string]$Path = "."'),
    t({ '', ')', '', 'begin {', '    ' }),
    i(2, '# init'),
    t({ '', '}', '', 'process {', '    ' }),
    i(3, '# work'),
    t({ '', '}', '', 'end {', '    ' }),
    i(4, '# cleanup'),
    t({ '', '}' }),
  }),
})
ls.add_snippets('powershell', ls.get_snippets('ps1'))

local map_opts = { expr = true, silent = true, desc = 'LuaSnip jump/expand' }
Myfn.map({ 'i', 's' }, '<C-j>', function()
  return ls.expand_or_jumpable() and '<Plug>luasnip-expand-or-jump' or '<C-j>'
end, map_opts)
Myfn.map({ 'i', 's' }, '<C-k>', function()
  return ls.jumpable(-1) and '<Plug>luasnip-jump-prev' or '<C-k>'
end, map_opts)
Myfn.map('i', '<C-l>', function()
  return ls.choice_active() and '<Plug>luasnip-next-choice' or '<C-l>'
end, map_opts)

-- ── blink.cmp config ──────────────────────────────────────────────────────────
local function in_comment_or_string()
  local ok, ts = pcall(require, 'vim.treesitter')
  if not ok then
    return false
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1] - 1, pos[2]
  local ok_caps, caps = pcall(ts.get_captures_at_pos, 0, row, col)
  if not ok_caps or not caps then
    return false
  end
  for _, cap in ipairs(caps) do
    local name = cap.capture or cap
    if name == 'nospell' or name == '@nospell' then
      return false
    end
    if name:match('^@?comment$') or name:match('^@?string$') then
      return true
    end
  end
  return false
end

local prose_fts_set = {
  text = true,
  gitcommit = true,
  rst = true,
  latex = true,
  markdown = true,
  [''] = true,
}
local function enable_spell_context()
  return prose_fts_set[vim.bo.filetype] or in_comment_or_string()
end

require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
  signature = { enabled = true, window = { border = 'rounded' } },

  completion = {
    menu = {
      auto_show = function(ctx)
        return ctx.mode ~= 'cmdline'
      end,
      border = 'rounded',
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind_icon' },
          { 'source_name' },
        },
      },
    },
    documentation = { auto_show = true, window = { border = 'rounded' } },
    trigger = { show_in_snippet = false },
    list = { selection = { preselect = false, auto_insert = false } },
  },

  sources = {
    default = { 'buffer', 'path', 'spell' },
    per_filetype = {
      [''] = { 'buffer', 'path', 'spell' },
      lua = { 'buffer', 'lsp', 'path', 'snippets' },
      sh = { 'buffer', 'lsp', 'path', 'snippets' },
      ps1 = { 'lsp', 'buffer', 'path', 'snippets' },
      python = { 'buffer', 'lsp', 'path', 'snippets' },
      javascript = { 'buffer', 'lsp', 'path', 'snippets' },
      typescript = { 'buffer', 'lsp', 'path', 'snippets' },
      markdown = { 'spell', 'buffer', 'path' },
      text = { 'spell', 'buffer', 'path' },
      gitcommit = { 'spell', 'buffer', 'path' },
      rst = { 'spell', 'buffer', 'path' },
      latex = { 'spell', 'buffer', 'path' },
    },
    providers = {
      lsp = { score_offset = 3, fallbacks = {} },
      buffer = {
        score_offset = 10,
        min_keyword_length = 2,
        opts = {
          get_bufnrs = function()
            return { vim.api.nvim_get_current_buf() }
          end,
        },
      },
      path = { score_offset = 2 },
      snippets = { score_offset = 1 },
      cmdline = { score_offset = 1 },
      spell = {
        name = 'Spell',
        module = 'blink-cmp-spell',
        score_offset = 3,
        opts = {
          max_entries = 8,
          preselect_current_word = false,
          keep_all_entries = false,
          use_cmp_spell_sorting = false,
          enable_in_context = enable_spell_context,
        },
      },
    },
  },

  fuzzy = {
    implementation = 'lua', -- use Lua since we can't build Rust
    use_proximity = true,
    prebuilt_binaries = { download = false }, -- stop trying to download
  },
})

pcall(function()
  local cmdline = require('blink.cmp.cmdline')
  if cmdline and cmdline.setup then
    cmdline.setup({ cmdline = { enabled = true }, search = { enabled = true } })
  end
end)

-- ── Spell / prose autocmds ────────────────────────────────────────────────────
local SPELL_LANGS = { 'en' }
local spellfile_path = vim.fs.normalize(
  vim.fn.stdpath('config') .. '/spell/' .. (SPELL_LANGS[1] or 'en') .. '.utf-8.add'
)
do
  local dir = vim.fs.dirname(spellfile_path)
  if dir and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit', 'rst', 'latex' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = SPELL_LANGS
    vim.opt_local.spellfile = spellfile_path
    vim.opt_local.conceallevel = 2
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
  desc = 'Enable spell (and comfy settings) for prose buffers',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'bash',
    'c',
    'cpp',
    'go',
    'java',
    'javascript',
    'jsx',
    'kotlin',
    'lua',
    'ps1',
    'python',
    'rust',
    'sh',
    'tsx',
    'typescript',
    'zsh',
  },
  callback = function()
    vim.opt_local.spell = false
  end,
  desc = 'Disable spell for code buffers',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sh', 'bash', 'zsh' },
  callback = function()
    vim.opt_local.iskeyword:append('-')
  end,
  desc = 'Shell editing comfort',
})
