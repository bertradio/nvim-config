-- lua/plugins/noice.lua
-- Noice: commandline + messages UI
-- Code from ChatGPT

return {
  'folke/noice.nvim',
  event = 'CmdlineEnter', -- ensures popup is ready for your first :
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    -- Make sure floating cmdline can show
    vim.opt.cmdheight = 0

    local sethl = vim.api.nvim_set_hl
    sethl(0, 'NoiceCmdlinePopupBorder', { fg = '#FFA500', bg = 'NONE' })
    sethl(0, 'NoiceMini', { link = 'NormalFloat' })

    require('noice').setup({
      lsp = {
        -- keep default LSP markdown handling
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
          ['vim.lsp.util.stylize_markdown'] = false,
          ['cmp.entry.get_documentation'] = false,
        },
        signature = { enabled = true },
        progress = { enabled = true }, -- we’ll filter spam below
        doc = { border = { style = 'rounded' } },
      },

      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        format = {
          cmdline = { pattern = '^:', icon = '', lang = 'vim', title = ' cmdline ' },
          search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
          search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
          lua = {
            pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
            icon = '',
            lang = 'lua',
            title = ' lua ',
          },
          help = { pattern = '^:%s*he?l?p?%s+', icon = ':h', title = ' help ' },
          input = {},
        },
      },

      messages = {
        enabled = true,
        view = 'notify',
        view_error = 'notify',
        view_warn = 'notify',
        view_history = 'messages',
        view_search = 'mini', -- less intrusive than virtualtext
      },

      routes = {
        -- quiet common, unimportant messages
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' }, -- write stats
              { find = '; after #%d+' },
              { find = '; before #%d+' },
              { find = '^%d+ lines? yanked' },
              { find = '^%d+ lines? fewer' },
              { find = '^Already at newest change' },
              { find = '^search hit BOTTOM' },
            },
          },
          view = 'mini',
        },
        -- silence lua_ls progress only (keep others)
        { filter = { event = 'lsp', kind = 'progress', find = 'lua_ls' }, opts = { skip = true } },
      },

      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },

      views = {
        cmdline_popup = {
          position = { row = 14, col = '50%' },
          size = { width = 60, height = 'auto' },
          border = { style = 'rounded' },
          win_options = { winhighlight = { FloatBorder = 'NoiceCmdlinePopupBorder' } },
        },

        -- If you use blink-cmp, keep backend = "nui" or "native"
        popupmenu = {
          enabled = true,
          backend = 'nui',
          relative = 'editor',
          position = { row = 15, col = '50%' },
          size = { width = 60, height = 10 },
          border = { style = 'rounded', padding = { 0, 1 } },
          win_options = {
            winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
          },
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

    -- match notify look/feel with noice
    local ok, notify = pcall(require, 'notify')
    if ok then
      notify.setup({ stages = 'fade', render = 'default', timeout = 2500, top_down = false })
    end
  end,
}
