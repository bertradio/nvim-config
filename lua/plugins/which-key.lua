-- which-key.lua
-- modified for v3 by Gemini

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 2000
  end,

  opts = {

    delay = 500, -- controls time before menu pops up is 1/1000 sec

    -- 1. PRESET (MOVED TO TOP LEVEL)
    preset = 'modern',

    layout = {
      align = 'center',
      width = { min = 25 },
      spacing = 8, -- Add more space between columns for a cleaner look
    },

    -- 2. GROUP NAMES

	  -- stylua: ignore
    spec = {
      { '<leader>b',  group = 'Buffer' },
      { '<leader>d',  group = 'Diff' },
      { '<leader>e',  group = 'Edit config' },
      { '<leader>f',  group = 'FZF' },
      { '<leader>fg', group = 'Grep' },
      { '<leader>g',  group = 'Git' },
    },

    -- 3. WINDOW
    win = {
      border = 'double',
      -- You can usually delete this "win" section entirely if you use a preset,
      -- unless you want to force a specific border style on top of the preset.
    },

    -- 4. SCROLLING
    keys = {
      scroll_down = '<Down>',
      scroll_up = '<Up>',
    },

    -- 5. ICONS
    icons = {
      breadcrumb = '»',
      separator = '➜',
      group = '+',
    },

    -- 6. KEY REPLACEMENTS
    replace = {
      ['<space>'] = 'SPC',
      ['<cr>'] = 'RET',
      ['<tab>'] = 'TAB',
    },

    -- 7. PLUGINS
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
  },
}
