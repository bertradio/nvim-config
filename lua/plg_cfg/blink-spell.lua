--    ╭────────────────────────────╮
--    │      blink-spell.lua       │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- Finalized 3-31-26: Fixed cmdline keymap hijacking and E5113 error
-- Optimized for Nvim 0.12 native features and sub-100ms startup
-- Added LuaSnip and friendly-snippets per Gemini 4-22-26
-- Revised for mini.cmdline compatibility 5-03-26

vim.pack.add({
  { src = Gh('L3MON4D3/LuaSnip'), run = 'make install_jsregexp' },
  Gh('ribru17/blink-cmp-spell'),
  { src = Gh('saghen/blink.cmp'), version = 'v1.10.2' },
})

--  ──────── add my custom snippets ─────────

require('plg_cfg.my_snippets')

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

  snippets = {
    preset = 'luasnip',
  },

  appearance = { nerd_font_variant = 'mono' },
  signature = { enabled = true, window = { border = 'rounded' } },

  -- stylua: ignore 
  keymap = {
    preset        = 'default',
    ['<Up>']      = { 'select_prev', 'fallback' },
    ['<Down>']    = { 'select_next', 'fallback' },
    ['<C-space>'] = { 'show', 'show_documentation', 'hide' },
    ['<Tab>']     = { 'snippet_forward', 'accept', 'fallback' },
    ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
    ['<CR>']      = { 'fallback' },
  },

  -- stylua: ignore 
  cmdline = {
    enabled = true,
    -- Removed 'preset = none' to allow blink to handle navigation properly
    keymap = {
      ['<Up>']   = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Tab>']  = { 'accept', 'fallback' },
      -- Added C-n/C-p as reliable alternatives for mini.cmdline
      ['<C-n>']  = { 'select_next', 'fallback' },
      ['<C-p>']  = { 'select_prev', 'fallback' },
    },
    completion = {
      menu       = { auto_show = true },
      ghost_text = { enabled   = true },
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
      border = 'rounded',
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind_icon' },
          { 'source_name' },
        },
      },
    },

    -- stylua: ignore 
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
      enabled = true,
      show_without_selection = true,
    },

    list = {
      selection = {
        preselect = true,
        auto_insert = false,
      },
    },
  },

  sources = {
    default = { 'lsp', 'snippets', 'buffer', 'path', 'spell' },

    -- stylua: ignore 
    providers = {
      lsp = { name = 'LSP', module = 'blink.cmp.sources.lsp', score_offset = 80 },
      snippets = { name = 'Snippets', module = 'blink.cmp.sources.snippets', score_offset = 80 },
      buffer = {
        name               = 'Buffer',
        module             = 'blink.cmp.sources.buffer',
        score_offset       = 80,
        min_keyword_length = 2,
      },
      spell = {
        name         = 'Spell',
        module       = 'blink-cmp-spell',
        score_offset = 80,
        opts         = { enable_in_context = enable_spell_context },
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

--  ───── Spell / prose autocmds to enable or disable spellcheck ─────

local SPELL_LANGS = { 'en' }
local spellfile_path = vim.fs.normalize(vim.fn.stdpath('config') .. '/spell/en.utf-8.add')
vim.opt.spellfile = spellfile_path

-- stylua: ignore 
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit', 'rst', 'latex' },
  callback = function()
    vim.opt_local.spell        = true
    vim.opt_local.spelllang    = SPELL_LANGS
    vim.opt_local.spellfile    = spellfile_path
    vim.opt_local.conceallevel = 2
    vim.opt_local.wrap         = true
    vim.opt_local.linebreak    = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'lua', 'python', 'sh', 'ps1' },
  callback = function()
    vim.opt_local.spell = false
  end,
})
