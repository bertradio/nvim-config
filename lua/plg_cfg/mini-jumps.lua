--    ╭────────────────────────────╮
--    │       mini-jumps.lua       │
--    ╰────────────────────────────╯

-- 08/01/26 - mini.jump and mini.jump2d split from mini.loa

local jump2d = require('mini.jump2d')
local mjump = require('mini.jump')

--  ─────────────────────────────────── mini.jump ───────────────────────────────────
-- code from ChatGPT
-- Improved f, F, t, and T motions.

mjump.setup({
  mappings = {
    forward = 'f',
    backward = 'F',
    forward_till = 't',
    backward_till = 'T',
    repeat_jump = ';',
  },

  delay = {
    -- Wait before highlighting additional matching characters.
    highlight = 0,

    -- Effectively disables automatic timeout.
    idle_stop = 10000000,
  },

  silent = true,
})

--  ────────── mini.jump2d ───────────

-- code from ChatGPT
-- Press s and choose a label at the beginning of a word.
-- S to select beginning of words
-- gl for beginning of lines

jump2d.setup({
  -- Disable the module's default <CR> mapping.
  mappings = {
    start_jumping = '',
  },

  -- Most convenient labels appear first.
  labels = 'asdfghjklqwertyuiopzxcvbnm',

  view = {
    dim = true,

    -- Show only the next label needed.
    n_steps_ahead = 0,
  },

  allowed_lines = {
    blank = false,
    cursor_before = true,
    cursor_at = true,
    cursor_after = true,
    fold = true,
  },

  allowed_windows = {
    current = true,
    not_current = true,
  },

  silent = true,
})

-- Flash-like jump to the beginning of a word.
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  jump2d.start(jump2d.builtin_opts.word_start)
end, {
  desc = 'Jump to word start',
})

-- Optional: jump to any occurrence of a typed character.
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  jump2d.start(jump2d.builtin_opts.single_character)
end, {
  desc = 'Jump to character',
})

-- Optional: jump to the beginning of a visible line.
vim.keymap.set({ 'n', 'x', 'o' }, 'gl', function()
  jump2d.start(jump2d.builtin_opts.line_start)
end, {
  desc = 'Jump to line start',
})

--  ───── Highlights for Catppuccin Mocha ─────

local function set_jump_highlights()
  -- mini.jump matching characters
  vim.api.nvim_set_hl(0, 'MiniJump', {
    fg = '#f9e2af',
    bold = true,
    underline = true,
  })

  -- mini.jump2d labels
  vim.api.nvim_set_hl(0, 'MiniJump2dSpot', {
    fg = '#1e1e2e',
    bg = '#f9e2af',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dSpotUnique', {
    fg = '#1e1e2e',
    bg = '#a6e3a1',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dSpotAhead', {
    fg = '#1e1e2e',
    bg = '#89b4fa',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dDim', {
    fg = '#6c7086',
  })
end

set_jump_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_jump_highlights,
})

--  ──────── end junp2d setup ────────
