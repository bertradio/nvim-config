--    ╭────────────────────────────╮
--    │      blink-spell.lua       │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup
-- Added LuaSnip and friendly-snippets per Gemini 4-22-26
-- Code revised as per Gemini

vim.pack.add({
  Gh('L3MON4D3/LuaSnip'),
  Gh('ribru17/blink-cmp-spell'),
  Gh('rafamadriz/friendly-snippets'),
  { src = Gh('saghen/blink.cmp'), version = 'v1.10.2' },
})

-- Load snippets from friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load({
  exclude = { 'fortran', 'java', 'cobol', 'c', 'c++' },
})

--  ──────── add my snippets ─────────

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node

ls.add_snippets('all', {
  s('copy', {
    t('Copyright (c) 2026 Bert Kleinman. All rights reserved.'),
  }),
})

-- ── Helper Functions for Spell Gating ───────────────────────────────────────

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

-- ── blink.cmp config ──────────────────────────────────────────────────────────

require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation', 'hide' },
    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Right>'] = { 'accept', 'fallback' }, -- Accept ghost text in the buffer},
  },

  cmdline = {
    enabled = true,
    keymap = {
      preset = 'none',
      ['<Tab>'] = { 'select_and_accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
    },
    completion = {
      menu = { auto_show = true },
      ghost_text = { enabled = true },
    },
    sources = function()
      local type = vim.fn.getcmdtype()
      if type == '/' or type == '?' then
        return { 'buffer' }
      end
      if type == ':' or type == '@' then
        return { 'cmdline' }
      end
      return {}
    end,
  },

  snippets = {
    preset = 'luasnip',
  },

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

    -- 1. Ensure documentation shows as soon as the item is selected
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0, -- Set to 0 for instant display
      window = { border = 'rounded' },
    },

    trigger = {
      show_in_snippet = false,
      show_on_keyword = true,
    },

    -- This enables ghost text globally for all buffers
    ghost_text = {
      enabled = true,
      -- Optional: show ghost text even when the menu is hidden
      show_without_selection = true,
    },

    list = {
      selection = {
        preselect = true, -- Required for ghost text to know what to preview
        auto_insert = false,
      },
    },
  },

  sources = {
    default = { 'lsp', 'snippets', 'buffer', 'path', 'spell' },

    providers = {
      lsp = { name = 'LSP', module = 'blink.cmp.sources.lsp', score_offset = 100 },
      snippets = { name = 'Snippets', module = 'blink.cmp.sources.snippets', score_offset = 90 },
      spell = {
        name = 'Spell',
        module = 'blink-cmp-spell',
        score_offset = 70,
        opts = { enable_in_context = enable_spell_context },
      },
      buffer = {
        name = 'Buffer',
        module = 'blink.cmp.sources.buffer',
        score_offset = 80,
        min_keyword_length = 2,
      },
      path = { name = 'Path', module = 'blink.cmp.sources.path', score_offset = 60 },
    },

    -- stylua: ignore 
    per_filetype = {
      markdown = { 'buffer', 'spell', 'snippets', 'path'  },
      lua      = { 'lsp', 'snippets', 'buffer', 'path' },
      bash     = { 'lsp', 'snippets', 'path' },
    },
  },
})

-- ── Spell / prose autocmds ────────────────────────────────────────────────────

local SPELL_LANGS = { 'en' }
local spellfile_path = vim.fs.normalize(vim.fn.stdpath('config') .. '/spell/en.utf-8.add')

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
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'lua', 'python', 'sh', 'ps1' },
  callback = function()
    vim.opt_local.spell = false
  end,
})
