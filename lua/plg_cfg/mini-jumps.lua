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
-- Press s and choose a label
-- S to select beginning of words
-- gl for beginning of lines

jump2d.setup({
  -- Disable the module's default <CR> mapping.
  mappings = {
    start_jumping = '', -- disable start_jumping
  },

  -- Most convenient labels appear first.
  labels = 'asdfghjklqwertyuiopzxcvbnm',

  view = {
    dim = false,

    -- Show only the next label needed.
    n_steps_ahead = 10,
  },

  allowed_lines = {
    blank = false,
    cursor_before = false,
    cursor_at = true,
    cursor_after = true,
    fold = false,
  },

  allowed_windows = {
    current = true,
    not_current = true,
  },

  silent = true,
})

-- Jump to any occurrence of a typed character.
Kset({ 'n', 'x', 'o' }, 's', function()
  jump2d.start(jump2d.builtin_opts.single_character)
end, {
  desc = 'Jump to character',
})

-- Jump to the beginning of a visible line.
Kset({ 'n', 'x', 'o' }, 'gl', function()
  jump2d.start(jump2d.builtin_opts.line_start)
end, {
  desc = 'Jump to line start',
})

--  ───── Highlights for Catppuccin Mocha ─────

local function set_jump_highlights()
  -- mini.jump matching characters
  vim.api.nvim_set_hl(0, 'MiniJump', {
    fg = '#f9e2af',
    -- fg = '#1e1e2e',
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
