-- completion.lua (Hybrid: native + mini.completion)
-- Replaces blink.cmp + blink-cmp-spell
-- Optimized for Nvim 0.12

-- ── Plugin ───────────────────────────────────────────────────────────
vim.pack.add({
  { src = 'https://github.com/echasnovski/mini.completion' },
})

-- ── Native Snippet Jumps (unchanged) ─────────────────────────────────
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  else
    return '<C-j>'
  end
end, { expr = true, silent = true, desc = 'Snippet jump forward' })

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  else
    return '<C-k>'
  end
end, { expr = true, silent = true, desc = 'Snippet jump backward' })

-- ── Treesitter Context Detection (unchanged) ─────────────────────────
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

-- ── mini.completion Setup ────────────────────────────────────────────
require('mini.completion').setup({
  delay = { completion = 100, info = 200, signature = 50 },

  window = {
    info = { border = 'rounded' },
    signature = { border = 'rounded' },
  },

  lsp_completion = {
    source_func = 'completefunc',
    auto_setup = false,
  },
})

-- ── Completion Behavior (sorting + tuning) ───────────────────────────

vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }

-- Completion sources
vim.opt.complete = { '.', 'w', 'b', 'k', 'f' }

-- Context-aware completion (spell vs code)
local function set_complete_for_context()
  if enable_spell_context() then
    vim.opt_local.complete = { 'kspell', 'k', 'f' }
  else
    vim.opt_local.complete = { '.,w', 'k', 'f' }
  end
end

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI' }, {
  callback = set_complete_for_context,
})

-- ── Keymaps (blink-like feel) ────────────────────────────────────────
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>' -- accept
  end
  return '<Tab>'
end, { expr = true, silent = true })

vim.keymap.set('i', '<Down>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  end
  return '<Down>'
end, { expr = true, silent = true })

vim.keymap.set('i', '<Up>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  end
  return '<Up>'
end, { expr = true, silent = true })

-- Force LSP completion (like your <C-space>)
vim.keymap.set('i', '<C-space>', function()
  return '<C-x><C-o>'
end, { expr = true, silent = true })

-- ── Spell / Prose Settings (unchanged) ───────────────────────────────
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
