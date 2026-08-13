--    ╭────────────────────────────╮
--    │         noice.lua          │
--    ╰────────────────────────────╯

-- 05/28/26 - Optimized as per Gemini

vim.pack.add({
  Gh('MunifTanjim/nui.nvim'),
  Gh('folke/noice.nvim'),
})

-- UI Customization: Orange theme for commandline border and icon
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  desc = 'Custom Noice highlights for orange theme',
  callback = function()
    vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', { fg = '#FFA500', bg = 'none' })
    vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', { fg = '#FFA500' })
  end,
})

-- Run it once immediately in case the colorscheme is already loaded
vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', { fg = '#FFA500', bg = 'none' })
vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', { fg = '#FFA500' })

require('noice').setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = false,
    },
  },
  routes = {
    {
      filter = {
        event = 'notify',
        find = '^cwd →',
      },
      view = 'mini',
      opts = { stop = true },
    },

    {
      -- Catch standard text changes, undo/redo, and add/delete echoes
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '%d+ lines?' },
          { find = '%d+ fewer lines' },
          { find = '%d+ more lines' },
          { find = 'before #%d+' },
          { find = 'after #%d+' },
          { find = 'Line %d+' },
          { find = 'undo' },
          { find = 'redo' },
          { find = 'written' },
        },
      },
      view = 'mini',
      opts = { stop = true },
    },

    {
      filter = { event = 'msg_show', kind = 'shell_cmd' },
      view = 'split',
      opts = { stop = true },
    },
  },
  presets = {
    bottom_search = false,
    command_palette = false, -- Kept false so the popup stays centered vertically
    long_message_to_split = true,
    inc_rename = false,
  },
  cmdline = {
    enabled = true,
    view = 'cmdline_popup',
    view_search = 'cmdline_popup', -- Forces search view into the centered floating box
    opts = {},
    format = {
      cmdline = { icon = '' },
      search_down = { icon = '' },
      search_up = { icon = '' },
    },
  },
  views = {
    cmdline_popup = {
      position = { row = 12, col = '50%' }, -- middle of screen
      -- position = { row = 16, col = '50%' }, -- row of command line box
      size = { width = 60, height = 'auto' },
      border = { style = 'rounded' },
    },
    mini = {
      backend = 'mini',
      relative = 'editor',
      align = 'message-left',
      timeout = 2000,
      position = { row = 2, col = '95%' },
      border = { style = 'rounded' },

      zindex = 1000,

      win_options = {
        wrap = true,
        winblend = 20,
        winhighlight = {
          Normal = 'NoiceMini',
          IncSearch = '',
          CurSearch = '',
          Search = '',
        },
      },
    },
  },
})
