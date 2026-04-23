--    ╭────────────────────────────╮
--    │         noice.lua          │
--    ╰────────────────────────────╯

-- Updated for Snacks Hybrid Setup - 4-16-26

-- disable lazyredraw while in Noice
vim.api.nvim_create_autocmd('User', {
  pattern = 'Noice',
  callback = function()
    vim.opt.lazyredraw = false
  end,
})

-- Load required UI plugins (Snacks is in snacks-config.lua)
vim.pack.add({
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
    {
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
  },
  -- stylua: ignore 
  presets = {
    bottom_search         = false,
    command_palette       = true, -- Centered cmdline
    long_message_to_split = true,
    inc_rename            = false,
  },
  -- stylua: ignore 
  cmdline = {
    enabled = true,
    view    = 'cmdline_popup', -- Centered popup
    format  = {
      cmdline     = { pattern = '^:', icon        = '', lang   = 'vim', title = ' cmdline ' },
      search_down = { kind    = 'search', pattern = '^/', icon  = '', lang    = 'regex' },
      search_up   = { kind    = 'search', pattern = '^%?', icon = '', lang    = 'regex' },
      lua         = {
        pattern = { '^:%s*lua%s+', '^:%s*lua%s *= %s*', '^:%s *= %s*' },
        icon    = '',
        lang    = 'lua',
        title   = ' lua ',
      },
      help = { pattern = '^:%s*he?l?p?%s+', icon = ':h', title = ' help ' },
    },
  },
  -- stylua: ignore 
  messages = {
    enabled      = true,
    view         = 'notify',
    view_error   = 'notify',
    view_warn    = 'notify',
    view_history = 'messages',
    view_search  = 'virtualtext',
  },
  -- stylua: ignore 
  views = {
    cmdline_popup = {
      position = { row   = 12, col    = '50%' },
      size     = { width = 60, height = 'auto' },
    },
    popupmenu = {
      enabled     = true,
      backend     = 'cmp',
      relative    = 'editor',
      position    = { row          = 15, col            = '50%' },
      size        = { width        = 60, height         = 10 },
      border      = { style        = 'rounded', padding = { 0, 1 } },
      win_options = { winhighlight = { Normal           = 'Normal', FloatBorder = 'DiagnosticInfo' } },
    },
    -- stylua: ignore 
    mini = {
      backend     = 'mini',
      relative    = 'editor',
      align       = 'message-left',
      timeout     = 3000,
      reverse     = true,
      focusable   = false,
      position    = { row   = 1, col = '95%' },
      size        = 'auto',
      border      = { style = 'rounded' },
      zindex      = 600,
      win_options = {
        wrap         = true,
        winbar       = '',
        foldenable   = true,
        winblend     = 20,
        winhighlight = {
          Normal    = 'NoiceMini',
          IncSearch = '',
          CurSearch = '',
          Search    = '',
        },
      },
    },
  },
})
