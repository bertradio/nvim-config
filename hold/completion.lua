-- completion.lua
-- Hybrid completion for Neovim 0.12:
--   * mini.completion for automatic LSP completion
--   * native buffer, path, and spelling completion as fallback
--   * native snippet expansion and navigation
--
-- Replaces blink.cmp and blink-cmp-spell.

-- vim.pack.add({
--   { src = 'https://github.com/nvim-mini/mini.completion' },
-- })

vim.pack.add({
  {
    src = 'https://github.com/Saghen/blink.cmp',
    version = 'v1.10.2',
  },
})

-- ── Native snippet navigation ────────────────────────────────────────────────

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ''
  end

  return '<C-j>'
end, {
  expr = true,
  silent = true,
  desc = 'Snippet jump forward',
})

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ''
  end

  return '<C-k>'
end, {
  expr = true,
  silent = true,
  desc = 'Snippet jump backward',
})

-- ── Detect prose, comments, and strings ──────────────────────────────────────

local prose_filetypes = {
  [''] = true,
  gitcommit = true,
  latex = true,
  markdown = true,
  rst = true,
  text = true,
}

local function in_comment_or_string()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, row, col)

  if not ok or not captures then
    return false
  end

  for _, capture in ipairs(captures) do
    local name = capture.capture or capture

    if name == 'comment' or name == '@comment' or name == 'string' or name == '@string' then
      return true
    end
  end

  return false
end

local function spell_completion_context()
  return prose_filetypes[vim.bo.filetype] == true or in_comment_or_string()
end

-- ── Native fallback completion sources ───────────────────────────────────────
--
-- mini.completion first requests LSP results. If LSP completion is unavailable
-- or returns no useful results, its fallback action invokes native <C-n>
-- completion using the sources configured in 'complete'.
--
-- Source meanings:
--   .       current buffer
--   w       buffers displayed in other windows
--   b       other loaded buffers
--   f       file names
--   kspell  spelling suggestions

local code_sources = {
  '.',
  'w',
  'b',
  'f',
}

local prose_sources = {
  'kspell',
  '.',
  'w',
  'b',
  'f',
}

local function update_completion_sources()
  if spell_completion_context() then
    vim.opt_local.complete = prose_sources
  else
    vim.opt_local.complete = code_sources
  end
end

-- Update when entering Insert mode and as the cursor moves between code,
-- comments, and strings.
local completion_group = vim.api.nvim_create_augroup('HybridCompletionSources', { clear = true })

vim.api.nvim_create_autocmd({
  'BufEnter',
  'FileType',
  'InsertEnter',
  'CursorMovedI',
}, {
  group = completion_group,
  callback = update_completion_sources,
})

-- ── Completion menu behavior ─────────────────────────────────────────────────
--
-- "nearest" prioritizes current-buffer matches near the cursor.
-- It intentionally is not combined with "fuzzy", because Neovim documents
-- that "nearest" has no effect when fuzzy matching is enabled.

vim.opt.completeopt = {
  'menuone',
  'noselect',
  'nearest',
  'popup',
}

vim.opt.shortmess:append('c')

-- Neovim 0.12 popup-menu border.
if vim.fn.exists('+pumborder') == 1 then
  vim.opt.pumborder = 'rounded'
end

-- ── mini.completion ──────────────────────────────────────────────────────────

require('mini.completion').setup({
  delay = {
    completion = 100,
    info = 200,
    signature = 100,
  },

  window = {
    info = {
      border = 'rounded',
    },
    signature = {
      border = 'rounded',
    },
  },

  lsp_completion = {
    -- mini.completion installs its LSP completefunc automatically.
    -- Do not also call vim.lsp.completion.enable() globally.
    source_func = 'completefunc',
    auto_setup = true,

    -- nil uses mini.completion's standard LSP filtering and sorting.
    process_items = nil,

    -- Current mini.completion falls back to vim.snippet.expand().
    snippet_insert = nil,
  },

  -- Use native completion when LSP completion has nothing appropriate.
  fallback_action = '<C-n>',
})

-- ── Completion keymaps ────────────────────────────────────────────────────────

-- Match the old blink behavior:
--   Tab accepts the selected completion.
--   If nothing is selected, it selects and accepts the first item.
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    local info = vim.fn.complete_info({ 'selected' })

    if info.selected == -1 then
      return '<C-n><C-y>'
    end

    return '<C-y>'
  end

  return '<Tab>'
end, {
  expr = true,
  silent = true,
  desc = 'Accept completion',
})

vim.keymap.set('i', '<Down>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  end

  return '<Down>'
end, {
  expr = true,
  silent = true,
  desc = 'Next completion',
})

vim.keymap.set('i', '<Up>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  end

  return '<Up>'
end, {
  expr = true,
  silent = true,
  desc = 'Previous completion',
})

-- Manually request mini.completion's LSP completion.
vim.keymap.set('i', '<C-Space>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-e>'
  end

  return vim.api.nvim_replace_termcodes('<C-x><C-u>', true, false, true)
end, {
  expr = true,
  silent = true,
  desc = 'Trigger LSP completion',
})

-- Optional direct native completion commands:
vim.keymap.set('i', '<C-x>s', '<C-x><C-s>', {
  remap = true,
  silent = true,
  desc = 'Spell completion',
})

vim.keymap.set('i', '<C-x>f', '<C-x><C-f>', {
  remap = true,
  silent = true,
  desc = 'Path completion',
})

-- ── Spell and prose settings ─────────────────────────────────────────────────

local spell_languages = { 'en' }

local spellfile = vim.fs.normalize(vim.fn.stdpath('config') .. '/spell/en.utf-8.add')

local prose_group = vim.api.nvim_create_augroup('ProseSettings', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = prose_group,
  pattern = {
    'gitcommit',
    'latex',
    'markdown',
    'rst',
    'text',
  },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = spell_languages
    vim.opt_local.spellfile = spellfile
    vim.opt_local.conceallevel = 2
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    update_completion_sources()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = prose_group,
  pattern = {
    'bash',
    'lua',
    'ps1',
    'python',
    'sh',
  },
  callback = function()
    vim.opt_local.spell = false
    update_completion_sources()
  end,
})

-- ── Blink command-line completion only ──────────────────────────────────────

require('blink.cmp').setup({
  -- Disable Blink in Insert mode.
  -- Command-line completion is configured separately below.
  enabled = function()
    return false
  end,

  -- Although Insert-mode completion is disabled, the command-line menu
  -- still uses these shared menu appearance settings.
  completion = {
    menu = {
      border = 'rounded',
    },
    documentation = {
      window = {
        border = 'rounded',
      },
    },
  },

  cmdline = {
    enabled = true,

    keymap = {
      preset = 'none',

      ['<Tab>'] = { 'select_and_accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-Space>'] = { 'show', 'fallback' },
    },

    completion = {
      menu = {
        auto_show = true,
      },
      ghost_text = {
        enabled = false,
      },
    },

    sources = function()
      local cmdtype = vim.fn.getcmdtype()

      if cmdtype == '/' or cmdtype == '?' then
        return { 'buffer' }
      end

      if cmdtype == ':' or cmdtype == '@' then
        return { 'cmdline' }
      end

      return {}
    end,
  },

  fuzzy = {
    implementation = 'lua',
    prebuilt_binaries = {
      download = false,
    },
  },
})
