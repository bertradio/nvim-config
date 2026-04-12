-- which-key.lua
-- changed from lazy to vim.pack 3-30-26

vim.pack.add({ Gh('folke/which-key.nvim') })

vim.o.timeout = true
vim.o.timeoutlen = 2000

require('which-key').setup({
  delay = 500,
  preset = 'modern',

  layout = {
    align = 'center',
    width = { min = 25 },
    spacing = 8,
  },

  -- stylua: ignore
  spec = {
    { "<leader>b",  group = "Buffer" },
    { "<leader>d",  group = "Diff" },
    { "<leader>e",  group = "Edit config" },
    { "<leader>f",  group = "FZF" },
    { "<leader>fg", group = "Grep" },
    { "<leader>g",  group = "Git" },
    { "<leader>l",  group = "Snacks" },
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

  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = false,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
})
