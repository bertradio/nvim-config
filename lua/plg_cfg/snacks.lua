--    ╭────────────────────────────╮
--    │         snacks.lua         │
--    ╰────────────────────────────╯

-- Explorer: Removed custom copy and move actions since they did not seem stable
-- Just using noice
-- 05/01/26 - set up dashboard to be default on start
-- 05/02/26 - added code per ChatGPT to ensure snacks.recent is kept up to date
--            but may be related to nvim 13. Not a problem with 12.2
-- 05/31/26 - moved notifications to bottom
-- 06/01/26 - set up dashboard to replace mini.starter
-- 06/05/26 - Tweaks as per claude

vim.pack.add({ Gh('folke/snacks.nvim') })

local snacks = require('snacks')

local excluded_exts = require('plg_cfg.file_exclude')

vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input.input


-- stylua: ignore
snacks.setup({

  --  ────── enable/disable modules ──────
  -- only include those not defined elsewhere

  bigfile      = { enabled = true },
  explorer     = { enabled = false },
  indent       = { enabled = true },
  input        = { enabled = true, border = 'double' },
  lazygit      = { enabled = true },
  quickfile    = { enabled = true },
  rename       = { enabled = true },
  scope        = { enabled = true },
  scroll       = { enabled = true },

  image        = { enabled = false },
  terminal     = { enabled = true },
  words        = { enabled = false },

  --  ──────── dashboard config ────────

  dashboard    = {
    enabled  = false,
    autokeys = "123456789abcdefghijklmnopqrstuvwxyz",
    width    = 50,
    row      = 4,

    sections = {
      {
        -- header  = "If it ain't broke, don't fix it!\n"
        -- section = "header",
      },
      {
        section = "recent_files",
        cwd = false,
        padding = 0,
        indent  = 2,
        limit   = 9, -- max number of recent files to display
      },
      -- Empty text row instead of dynamic section padding
      -- inserts line between recent and keys
      { text = "" },
      {
        section = "keys",
        padding = 0,
        indent  = 2
      },
    },

    preset = {
      -- header = "If it ain't broke, don't fix it!\n",
      header = "",

      keys = {
        { key = "f", desc = "Find Files",
          action = function()
            Snacks.picker.files({ title = Myfn.short_cwd() })
          end },
        { key = "g", desc = "Grep",       action = function() Snacks.picker.grep() end },
        -- { key = "o", desc = "Oil",        action = ":Oil" },
        { key = "y", desc = "Yazi",        action = "<Leader>x" },
        { key = "r",
          desc = "Recent Files",
          action = function()
            vim.cmd('wshada')
            vim.cmd('rshada!')
            snacks.picker.recent({ refresh = true, file_pos = "main" })
          end },
        { key = "s", desc = "Sessions", action = "<Leader>q"},
        { key = "q", desc = "Quit Menu", action = ":bwipeout" },
      },
    },
  },

  --  ────── Picker Configuration ──────

  picker       = {
    enabled   = true,
    layout    = "my_default",
    prompt    = '> ',
    ui_select = true,
    exclude   = excluded_exts,
    win       = {
      border = "double",
      preview = {
        wo = { number = false, relativenumber = false, signcolumn = 'no' },
      },
      input = {
        keys = {
          ['<PageUp>']   = { 'list_scroll_up', mode = { 'i', 'n' } },
          ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
        },
      },
    },

    --  ─────── my custom layouts ────────

    layouts   = {
      my_default = { -- 2 pane standard
        layout = {
          box    = 'horizontal',
          width  = 0.85,
          height = 0.85,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
          { win = 'preview', border = 'rounded', width = 0.65, title = '{preview}' },
        },
      },
      my_spelling = { -- single pane narrow
        layout = {
          box    = 'horizontal',
          width  = 0.5,
          height = 0.7,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
        },
      },
      my_keymaps = { -- single pane wide
        layout = {
          box    = 'horizontal',
          width  = 0.9,
          height = 0.7,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win = 'input',     height = 1,      border = 'bottom' },
            { win = 'list',      border = 'none' },
          },
        },
      },
    },

    --  ───── defaults for various pickers ─────

    sources   = {
      buffers         = { layout = { preset = 'my_default' } },
      command_history = { layout = { preset = 'my_spelling' } },
      files           = { layout = { preset = 'my_default' } },
      grep            = { layout = { preset = 'my_default' } },
      help            = { layout = { preset = 'my_default' } },
      jumps           = { layout = { preset = 'my_default' } },
      keymaps         = { layout = { preset = 'my_keymaps' } },
      lines           = { layout = { preset = 'my_keymaps' } },
      lsp_symbols     = { layout = { preset = "my_default" } },
      marks           = { layout = { preset = 'default' } },
      qflist          = { layout = { preset = 'my_default' } },
      recent          = {
        layout = { preset = "my_default" },
        filter = { cwd = false },
        file_pos = "main",
      },
      registers       = { layout = { preset = 'my_default' } },
      search_history  = { layout = { preset = 'my_spelling' } },
      undo            = { layout = { preset = 'my_default' } },
      zoxide          = { layout = { preset = 'my_keymaps' } },

      -- --  ──────── Explorer config ─────────
      --
      -- explorer        = {
      --   exclude       = {},   -- don't exclude any files
      --   -- replace_netrw = true, -- Replace netrw with the snacks explorer
      --   layout        = {
      --     { preview = true },
      --     layout = {
      --       box    = 'horizontal',
      --       height = 0.85,
      --       width  = 0.90,
      --       {
      --         border    = 'double',
      --         box       = 'vertical',
      --         title     = '{source} {live} {flags}',
      --         title_pos = 'center',
      --         { win = 'input',     height = 1,      border = 'bottom' },
      --         { win = 'list',      border = 'none' },
      --       },
      --       { win = 'preview', border = 'double', width = 0.65, title = '{preview}' },
      --     },
      --   },
      --   win           = {
      --     list = {
      --       keys = {
      --         ['<left>']     = 'explorer_up',
      --         ['g.']         = 'toggle_hidden',
      --         ['<PageUp>']   = { 'list_scroll_up', mode = { 'i', 'n' } },
      --         ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
      --       },
      --     },
      --   },
      --   auto_close    = true,
      --   diagnostics   = true,
      --   follow_file   = true,
      --   formatters    = {
      --     file = { filename_only = true },
      --     tree = true,
      --   },
      -- },
    },
  },

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

  -- commented out because it seems to cause problems with noice
  -- notifier     = {
  --   enabled = true,
  --   -- top_down = false, -- put notifier at bottom of the screen
  --   margin = {
  --     right = 1,
  --     bottom = 1,
  --   },
  -- },
})

-- force display of message when file saved
-- vim.api.nvim_create_autocmd('BufWritePost', {
--   group = vim.api.nvim_create_augroup('SnacksSaveNotify', { clear = true }),
--   callback = function(args)
--     -- Get just the filename, not the full system path
--     local filename = vim.fn.fnamemodify(args.file, ':t')
--
--     -- Trigger the notification via snacks
--     Snacks.notify.info(filename .. ' -> saved', { title = '' })
--   end,
-- })

--  ─────────── end snacks configs ───────────

--    ╭────────────────────────────╮
--    │        key mappings        │
--    ╰────────────────────────────╯

-- stylua: ignore 
local function maps()

  Kset('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>',            { desc = 'delete current' })
  Kset('n', '<Leader>sR', '<cmd>lua Snacks.picker.registers()<cr>',     { desc = 'registers' })
  Kset('n', '<Leader>sb', '<cmd>lua Snacks.picker.buffers()<cr>',       { desc = 'buffers' })
  Kset('n', '<Leader>sg', '<cmd>lua Snacks.picker.grep()<cr>',          { desc = 'grep' })
  Kset('n', '<Leader>sh', '<cmd>lua Snacks.picker.help()<cr>',          { desc = 'help' })
  Kset('n', '<Leader>sj', '<cmd>lua Snacks.picker.jumps()<cr>',         { desc = 'jumps' })
  Kset('n', '<Leader>sl', '<cmd>lua Snacks.picker.lines()<cr>',         { desc = 'buffer lines' })
  Kset('n', '<Leader>sm', '<cmd>lua Snacks.picker.marks()<cr>',         { desc = 'marks' })
  Kset('n', '<Leader>sn', '<cmd>lua Snacks.picker.notifications()<cr>', { desc = 'notifications' })
  Kset('n', '<Leader>sq', '<cmd>lua Snacks.picker.qflist()<cr>',        { desc = 'quick fix' })
  Kset('n', '<Leader>su', '<cmd>lua Snacks.picker.undo()<cr>',          { desc = 'undo history' })
  Kset('n', '<Leader>sy', '<cmd>lua Snacks.lazygit.open(opts)<cr>',     { desc = 'lazygit' })
  Kset('n', '<Leader>sz', '<cmd>lua Snacks.zen()<cr>',                  { desc = 'zen mode' })
  Kset('n', '<Leader>z', '<cmd>lua Snacks.picker.zoxide()<cr>',         { desc = 'Zoxide' })

  Kset(
    'n',
    '<Leader>sd',
    '<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
    { desc = 'diagnostics - buffer' }
  )

  Kset('n', '<Leader>sk', function()
    Snacks.picker.keymaps()
  end, { desc = 'keymaps' })

  -- Kset(
  --   'n',
  --   '<Leader>x',
  --   '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
  --   { desc = 'Explorer' }
  -- )

  Kset('n', '<Leader>ss', function()
    Snacks.picker({
      source = 'search_history',
    })
  end, { desc = 'search history' })

  Kset('n', '<space>]', function()
    vim.cmd('wshada')
    vim.cmd('rshada!')
    Snacks.dashboard.open()
  end, { desc = 'Dashboard (Synced)', silent = true })

  local function open_clean_recent_picker()
    Snacks.picker.recent({ file_pos = 'main' })
  end

  Kset('n', '<Leader>sr', function()
    vim.cmd('wshada')
    vim.cmd('rshada!')
    open_clean_recent_picker()
  end, { desc = 'Recent Files (Synced)' })

  Kset(
    'n',
    '<Leader>sw',
    '<cmd>lua Snacks.picker.grep_word()<cr>',
    { desc = 'grep selection or word' }
  )

  Kset('n', '<leader>i', function()
    if Snacks.indent.enabled then
      Snacks.indent.disable()
    else
      Snacks.indent.enable()
    end
  end, { desc = 'Toggle indent Guides' })

  Kset('n', '<Leader>sf', function()
    Snacks.picker({
      source = 'files',
      title = Myfn.short_cwd(),
    })
  end, { desc = 'files cwd' })

  Kset('n', '<Leader><space>', function()
    Snacks.picker({
      source = 'files',
      title = Myfn.short_cwd(),
    })
  end, { desc = 'Files cwd' })

  Kset('n', '<Leader>ba', function()
    Snacks.bufdelete.all()
    Snacks.dashboard.open()
  end, { desc = 'delete all' })

end

maps()
