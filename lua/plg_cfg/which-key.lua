--    ╭────────────────────────────╮
--    │       which-key.lua        │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26

vim.pack.add({ Gh('folke/which-key.nvim') })

require('which-key').setup({
  delay = 500,
  -- preset = 'modern',
  preset = 'helix', -- display lower right as mini.clue

  --  ───── labels for second character ─────

  -- stylua: ignore
  spec = {
    { "<Leader>b",  group = "Buffer" },
    { "<Leader>d",  group = "Diff" },
    { "<Leader>e",  group = "Edit config" },
    { "<Leader>f",  group = "Snacks" },
    { "<Leader>q",  group = "Quickfix" },
    { "<Leader>Q",  group = "Sessions" },
    { "<Leader>s",  group = "Surround" },
  },

  keys = {
    scroll_down = '<Down>',
    scroll_up = '<Up>',
  },

  icons = {
    breadcrumb = '»',
    separator = '➜',
    group = '+',
  },

  replace = {
    key = {
      function(key)
        return require('which-key.view').format(key)
      end,
      { '<Space>', 'SPC' },
      { '<CR>', 'RET' },
      { '<Tab>', 'TAB' },
    },
  },

  -- stylua: ignore 
  plugins = {
    marks     = true,
    registers = true,
    spelling  = {
        enabled = false,
    },
    presets = {
      operators    = true,
      motions      = true,
      text_objects = true,
      windows      = true,
      nav          = true,
      z            = true,
      g            = true,
    },
  },
})
