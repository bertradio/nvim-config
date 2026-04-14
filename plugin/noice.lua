--    ╭────────────────────────────╮
--    │         noice.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
--
-- display of error and other messages as well as commandline

-- disable lazyredraw while in Noice
vim.api.nvim_create_autocmd('User', {
  pattern = 'Noice',
  callback = function()
    vim.opt.lazyredraw = false
  end,
})

-- surpass Diagnosing workspace lua_ls messages
vim.lsp.handlers['$/progress'] = function() end

vim.pack.add({
  Gh('rcarriga/nvim-notify'),
  Gh('MunifTanjim/nui.nvim'),
  Gh('folke/noice.nvim'),
})

-- make border of commandline popup orange to match command color
vim.cmd([[
			highlight NoiceCmdlinePopupBorder guibg=none guifg=#FFA500
		]])

require('noice').setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = false,
    },
  },
  routes = {
    filter = {
      event = 'msg_show',
      any = {
        { find = '%d+L, %d+B' },
        { find = '; after #%d+' },
        { find = '; before #%d+' },
      },
    },
    view = 'mini',
  },
  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
  },

  cmdline = {
    enabled = true, -- enables the Noice cmdline UI
    view = 'cmdline_popup', -- view for rendering the cmdline
    format = {
      cmdline = {
        pattern = '^:',
        icon = '',
        lang = 'vim',
        title = ' cmdline ',
      },
      search_down = {
        kind = 'search',
        pattern = '^/',
        icon = ' ',
        lang = 'regex',
      },
      search_up = {
        kind = 'search',
        pattern = '^%?',
        icon = ' ',
        lang = 'regex',
      },
      lua = {
        pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
        icon = '',
        lang = 'lua',
        title = ' lua ',
      },
      help = {
        pattern = '^:%s*he?l?p?%s+',
        icon = ':h',
        title = ' help ',
      },
      input = {}, -- Used by input()
    },
  },
  messages = {
    enabled = true, -- enables the Noice messages UI
    view = 'notify',
    view_error = 'notify', -- view for errors
    view_warn = 'notify', -- view for warnings
    view_history = 'messages', -- view for :messages
    -- view_history = 'mini', -- view for :messages
    view_search = 'virtualtext', -- view for search count messages. Set to `false` to disable
  },
  views = {
    cmdline_popup = {
      position = { row = 12, col = '50%' },
      size = { width = 60, height = 'auto' },
    },
    popupmenu = {
      enabled = true,
      backend = 'cmp',
      relative = 'editor',
      position = { row = 15, col = '50%' },
      size = { width = 60, height = 10 },
      border = { style = 'rounded', padding = { 0, 1 } },
      win_options = { winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' } },
    },
    mini = {
      backend = 'mini',
      relative = 'editor',
      align = 'message-left',
      timeout = 3000,
      reverse = true,
      focusable = false,
      position = { row = 1, col = '95%' },
      size = 'auto',
      border = { style = 'rounded' },
      zindex = 600,
      win_options = {
        wrap = true,
        timeout = 1000,
        winbar = '',
        foldenable = true,
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
