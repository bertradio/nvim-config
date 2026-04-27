--    ╭────────────────────────────╮
--    │      blink-spell.lua       │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup
-- Added LuaSnip and friendly-snippets per Gemini 4-22-26
-- Code revised as per Gemini

vim.pack.add({
  { src = Gh('L3MON4D3/LuaSnip'), run = 'make install_jsregexp' },
  Gh('ribru17/blink-cmp-spell'),
  Gh('rafamadriz/friendly-snippets'),
  { src = Gh('saghen/blink.cmp'), version = 'v1.10.2' },
})

-- Load snippets from friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load({
  exclude = { 'fortran', 'java', 'cobol', 'c', 'c++', 'ruby' },
})

--  ──────── add my custom snippets ─────────

require('config/my_snippets')

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
    if name:match('comment') or name:match('string') then
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
  -- stylua: ignore
  keymap = {
    preset        = 'default',
    ['<Up>']      = { 'select_prev', 'fallback' },
    ['<Down>']    = { 'select_next', 'fallback' },
    ['<C-space>'] = { 'show', 'show_documentation', 'hide' },
    ['<Tab>']     = { 'snippet_forward', 'fallback' },
    ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
    ['<CR>']      = { 'accept', 'fallback' },
    -- ['<Right>'] = { 'accept', 'fallback' }, -- Accept ghost text in the buffer},
  },

  cmdline = {
    enabled = true,
    -- stylua: ignore
    keymap = {
      preset     = 'none',
      ['<Up>']   = { 'select_prev', 'fallback' },
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

  appearance = { nerd_font_variant = 'mono' },
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

    -- Ensure documentation shows as soon as the item is selected
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 150,
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

    -- all offsets set tne same so order below controls
    providers = {
      lsp = { name = 'LSP', module = 'blink.cmp.sources.lsp', score_offset = 80 },
      snippets = { name = 'Snippets', module = 'blink.cmp.sources.snippets', score_offset = 80 },
      buffer = {
        name = 'Buffer',
        module = 'blink.cmp.sources.buffer',
        score_offset = 80,
        min_keyword_length = 2,
      },
      spell = {
        name = 'Spell',
        module = 'blink-cmp-spell',
        score_offset = 80,
        opts = { enable_in_context = enable_spell_context },
      },
      path = { name = 'Path', module = 'blink.cmp.sources.path', score_offset = 80 },
    },

    -- stylua: ignore 
    per_filetype = {
      markdown = { 'spell', 'buffer', 'snippets', 'path' },
      lua      = { 'snippets', 'buffer', 'lsp', 'path' },
      bash     = { 'lsp', 'snippets', 'path', 'buffer' },
    },
  },
})

-- ── Spell / prose autocmds ────────────────────────────────────────────────────

local SPELL_LANGS = { 'en' }
local spellfile_path = vim.fs.normalize(vim.fn.stdpath('config') .. '/spell/en.utf-8.add')
vim.opt.spellfile = spellfile_path

-- setup for text files
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

-- setup for coding languages
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'lua', 'python', 'sh', 'ps1' },
  callback = function()
    vim.opt_local.spell = false
  end,
})
