-- blink.lua

-- changed from lazy to vim.pack 3-30-26
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup
-- Added LuaSnip and friendly-snippets per Gemini 4-22-26
-- Revised for mini.cmdline compatibility 5-03-26
-- 05/20/26 - Removed all spelling since never used

vim.pack.add({
  { src = Gh('L3MON4D3/LuaSnip'), run = 'make install_jsregexp' },
  { src = Gh('saghen/blink.cmp'), version = 'v1.10.2' },
})

local blink = require('blink.cmp')

--  ──────── add my custom snippets ─────────

require('plg_cfg.my_snippets')

-- ── blink.cmp config ──────────────────────────────────────────────────────────

-- stylua: ignore
blink.setup({

  snippets   = {
    preset = 'luasnip',
  },

  appearance = { nerd_font_variant = 'mono' },
  signature  = { enabled = true, window = { border = 'rounded' } },

  keymap     = {
    -- ['<C-space>'] = { 'show', 'show_documentation', 'hide' },
    ['<CR>']      = { 'fallback' },
    ['<Down>']    = { 'select_next', 'fallback' },
    ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
    ['<Tab>']     = { 'snippet_forward', 'accept', 'fallback' },
    ['<Up>']      = { 'select_prev', 'fallback' },
    preset        = 'default',
  },

  cmdline    = {
    enabled = true,
    keymap = {
      ['<C-n>']  = { 'select_next', 'fallback' },
      ['<C-p>']  = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Tab>']  = { 'accept', 'fallback' },
      ['<Up>']   = { 'select_prev', 'fallback' },
    },
    completion = {
      ghost_text = { enabled = false },
      menu       = { auto_show = true },
    },
    sources = function()
      local type = vim.fn.getcmdtype()
      -- Search mode
      if type == '/' or type == '?' then
        return { 'buffer' }
      end
      -- Command mode: Added '>' and '=' for broader coverage
      if type == ':' or type == '@' or type == '>' or type == '=' then
        return { 'cmdline' }
      end
      return {}
    end,
  },

  completion = {
    menu = {
      -- Set to true to ensure the menu logic initializes correctly in cmdline
      auto_show = true,
      border    = 'rounded',
      draw      = {
        columns = {
          { 'label',      'label_description', gap = 1 },
          { 'kind_icon' },
          { 'source_name' },
        },
      },
    },

    documentation = {
      auto_show          = true,
      auto_show_delay_ms = 150,
      window             = { border = 'rounded' },
    },

    trigger = {
      show_in_snippet = false,
      show_on_keyword = true,
    },

    ghost_text = {
      enabled                = true,
      show_without_selection = true,
    },

    list = {
      selection = {
        auto_insert = false,
        preselect   = true,
      },
    },
  },

  sources    = {
    default = { 'lsp', 'snippets', 'buffer', 'path' },

    providers = {
      buffer   = {
        name               = 'Buffer',
        module             = 'blink.cmp.sources.buffer',
        score_offset       = 80,
        min_keyword_length = 2,
      },
      lsp      = { name = 'LSP', module = 'blink.cmp.sources.lsp', score_offset = 80 },
      snippets = { name = 'Snippets', module = 'blink.cmp.sources.snippets', score_offset = 80 },
      path     = { name = 'Path', module = 'blink.cmp.sources.path', score_offset = 80 },
    },

    per_filetype = {
      bash     = { 'lsp', 'snippets', 'path', 'buffer' },
      lua      = { 'snippets', 'buffer', 'lsp', 'path' },
      markdown = { 'buffer', 'snippets', 'path' },
    },
  },
})
