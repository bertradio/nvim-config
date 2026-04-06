-- blink-spell.lua
-- changed from lazy to -- vim.pack 3-30-26
--
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup

-- vim.pack.add({
--   { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.2' },
--   { src = 'https://github.com/ribru17/blink-cmp-spell' },
-- })

-- ── Native Snippet Jumps ────────────────────────────────────────────────────
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  else
    return '<C-j>'
  end
end, { expr = true, silent = true, desc = 'Native snippet jump forward' })

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  else
    return '<C-k>'
  end
end, { expr = true, silent = true, desc = 'Native snippet jump backward' })

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
  -- Global Keymaps (Insert mode)
  keymap = {
    preset = 'none',
    ['<Tab>'] = { 'select_and_accept', 'fallback' },
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
  },

  -- Cmdline Config (Explicitly overrides floating UI hijacking)
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
      ghost_text = { enabled = false },
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

  -- Native Snippet Bridge
  snippets = {
    preset = 'default',
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
    documentation = { auto_show = true, window = { border = 'rounded' } },
    trigger = { show_in_snippet = false },
    list = { selection = { preselect = false, auto_insert = false } },
  },

  sources = {
    default = { 'lsp', 'snippets', 'buffer', 'path', 'spell' },
    per_filetype = {
      lua = { 'lsp', 'snippets', 'buffer', 'path' },
      sh = { 'lsp', 'snippets', 'buffer', 'path' },
      bash = { 'lsp', 'snippets', 'buffer', 'path' },
      ps1 = { 'lsp', 'snippets', 'buffer', 'path' },
      markdown = { 'spell', 'buffer', 'path', 'snippets' },
    },
    providers = {
      lsp = { name = 'LSP', module = 'blink.cmp.sources.lsp', score_offset = 3 },
      buffer = {
        name = 'Buffer',
        module = 'blink.cmp.sources.buffer',
        score_offset = 10,
        min_keyword_length = 2,
        opts = {
          get_bufnrs = function()
            return { vim.api.nvim_get_current_buf() }
          end,
        },
      },
      path = { name = 'Path', module = 'blink.cmp.sources.path', score_offset = 2 },
      snippets = { name = 'Snippets', module = 'blink.cmp.sources.snippets', score_offset = 1 },
      spell = {
        name = 'Spell',
        module = 'blink-cmp-spell',
        score_offset = 3,
        opts = {
          max_entries = 8,
          enable_in_context = enable_spell_context,
        },
      },
    },
  },

  fuzzy = {
    implementation = 'lua',
    use_proximity = true,
    prebuilt_binaries = { download = false },
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
