--    ╭────────────────────────────╮
--    │         blink.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup
-- Added LuaSnip and friendly-snippets per Gemini 4-22-26
-- Revised for mini.cmdline compatibility 5-03-26
-- 08/06/26 - removed Luasnip and my_snippets - moved to core
-- 09/18/26 - re-added spell for md and txt

vim.pack.add({
  Gh('ribru17/blink-cmp-spell'),
  { src = Gh('saghen/blink.cmp'), version = 'v1.10.2' },
})

local blink = require('blink.cmp')

-- ── blink.cmp config ──────────────────────────────────────────────────────────

-- stylua: ignore
blink.setup({

  signature  = { enabled = true, window = { border = 'rounded' } },

  keymap     = {
    -- ['<C-space>'] = { 'show', 'show_documentation', 'hide' },
    ['<CR>']      = { 'fallback' },
    ['<Down>']    = { 'select_next', 'fallback' },
    ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
    ['<Tab>']     = { 'snippet_forward', 'accept', 'fallback' },
    ['<Up>']      = { 'select_prev', 'fallback' },
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
       if type == ':' or type == '@' then
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
      auto_show_delay_ms = 250,
      window             = { border = 'rounded' },
    },

    trigger = {
      show_in_snippet = false,
    },

    ghost_text = {
      enabled = false,
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
    min_keyword_length = 2,
    per_filetype = {
      markdown = { 'spell', 'buffer', 'snippets', 'path' },
      text     = { 'spell', 'buffer', 'snippets', 'path' },
    },
    providers = {
      spell = {
        name = 'Spell',
        module = 'blink-cmp-spell',
        opts = { max_entries = 5 },
      },
    },
  },

  fuzzy = {
    sorts = {
      function(a, b)
        local ft = vim.bo.filetype
        if ft ~= 'markdown' and ft ~= 'text' then return end

        local priority = { spell = 1, buffer = 2 }
        local a_priority = priority[a.source_id] or 3
        local b_priority = priority[b.source_id] or 3
        if a_priority ~= b_priority then return a_priority < b_priority end
        if a.source_id == 'spell' and b.source_id == 'spell' then
          return require('blink.cmp.fuzzy.sort').sort_text(a, b)
        end
      end,
      'score',
      'sort_text',
    },
  },
})
