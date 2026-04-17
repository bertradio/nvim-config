--    ╭────────────────────────────╮
--    │     snacks-config.lua      │
--    ╰────────────────────────────╯

-- Updated: Centralized Snacks setup with Notifier - 4-16-26
-- Explorer: Removed custom copy and move since they did not seem stable

vim.pack.add({ Gh('folke/snacks.nvim') })

local excluded_exts = require('config.file_exclude')

require('snacks').setup({

  --  ───── Centralized Notification & Progress ─────
  notifier = {
    enabled = true,
    timeout = 3000,
  },

  --  ────── enable other modules ──────

  bigfile = { enabled = true },
  dashboard = { enabled = false }, -- start with dashboard disabled
  explorer = { enabled = true },
  input = { enabled = true },
  lazygit = { enabled = true },
  lsp_progress = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },

  statuscolumn = {
    enabled = true,
    segments = {
      { text = { '%s' }, click = 'v:lua.scsa' },
      { text = { '%c' } },
      {
        text = {
          function()
            if vim.v.virtnum ~= 0 then
              return ''
            end
            if vim.wo.relativenumber then
              local rel = math.abs(vim.fn.line('.') - vim.v.lnum)
              return (rel == 0 and vim.v.lnum or rel) .. ' '
            end
            return string.format('%d ', vim.v.lnum)
          end,
        },
        click = 'v:lua.scna',
      },
    },
  },

  picker = {
    enabled = true,
    prompt = '> ',
    ui_select = true,
    exclude = excluded_exts,
    win = {
      preview = {
        wo = { number = false, relativenumber = false, signcolumn = 'no' },
      },
      input = {
        keys = {
          ['<PageUp>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
          ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
        },
      },
    },

    --  ─────── my custom layouts ────────

    layouts = {
      my_default = { -- 2 pane standard
        layout = {
          box = 'horizontal',
          width = 0.9,
          height = 0.8,
          {
            box = 'vertical',
            border = 'rounded',
            title = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
          { win = 'preview', border = 'rounded', width = 0.65, title = '{preview}' },
        },
      },
      my_spelling = { -- single pane narrow
        layout = {
          box = 'horizontal',
          width = 0.5,
          height = 0.7,
          {
            box = 'vertical',
            border = 'rounded',
            title = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
        },
      },
      my_keymaps = { -- single pane wide
        layout = {
          box = 'horizontal',
          width = 0.9,
          height = 0.7,
          {
            box = 'vertical',
            border = 'rounded',
            title = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
        },
      },
    },

    -- defaults for various pickers
    -- stylua: ignore 
    sources = {
      buffers         = { layout = { preset = 'my_default' } },
      command_history = { layout = { preset = 'my_spelling' } },
      files           = { layout = { preset = 'my_default' } },
      grep            = { layout = { preset = 'my_default' } },
      help            = { layout = { preset = 'my_default' } },
      jumps           = { layout = { preset = 'my_default' } },
      keymaps         = { layout = { preset = 'my_keymaps' } },
      lines           = { layout = { preset = 'my_keymaps' } },
      lsp_symbols     = { layout = { preset = 'default' } },
      marks           = { layout = { preset = 'default' } },
      qflist          = { layout = { preset = 'my_default' } },
      recent          = { layout = { preset = 'my_default' } },
      registers       = { layout = { preset = 'my_default' } },
      search_history  = { layout = { preset = 'my_spelling' } },
      spelling        = { layout = { preset = 'my_spelling' } },
      undo            = { layout = { preset = 'my_default' } },
      zoxide          = { layout = { preset = 'my_keymaps' } },
      explorer = {
        layout = {
          { preview = true },
          layout = {
            box = 'horizontal',
            height = 0.85,
            width = 0.90,
            {
              border = 'rounded',
              box = 'vertical',
              title = '{source} {live} {flags}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'bottom' },
              { win = 'list', border = 'none' },
            },
            { win = 'preview', border = 'rounded', width = 0.65, title = '{preview}' },
          },
        },
        win = {
          list = {
            keys = {
              ['<left>'] = 'explorer_up',
              ['g.'] = 'toggle_hidden',
              ['<PageUp>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
              ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
            },
          },
        },
        auto_close = true,
        diagnostics = false,
        follow_file = true,
        formatters = {
          file = { filename_only = true },
          tree = true,
        },
      },
    },
  },
})

--  ───── Global override to ensure all plugins use Snacks for notifications ─────

vim.notify = function(msg, level, opts)
  require('snacks').notifier.notify(msg, level, opts)
end
