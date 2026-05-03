--    ╭────────────────────────────╮
--    │         snacks.lua         │
--    ╰────────────────────────────╯

-- Explorer: Removed custom copy and move actions since they did not seem stable
-- Just using noice
-- 05/01/26 - set up dashboard to be default on start
-- 05/02/26 - added code per ChatGPT to ensure snacks.recent is kept up to date
--            but may be related to nvim 13. Not a problem with 12.2

vim.pack.add({ 'https://www.github.com/folke/snacks.nvim' })

local excluded_exts = require('plg_cfg.file_exclude')

vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input.input

-- stylua: ignore
require('snacks').setup({

  --  ────── enable/disable modules ──────

  bigfile      = { enabled = true },
  explorer     = { enabled = true },
  indent       = { enabled = true },
  input        = { enabled = true, border = 'double' },
  lazygit      = { enabled = true },
  quickfile    = { enabled = true },
  rename       = { enabled = true },
  scope        = { enabled = true },
  scroll       = { enabled = true },

  image        = { enabled = false },
  notifier     = { enabled = false },
  terminal     = { enabled = false },
  words        = { enabled = false },

  -- stylua: ignore 
  picker = {
    enabled      = true,
    layout       = "my_default",
    prompt       = '> ',
    ui_select    = true,
    exclude      = excluded_exts,
    win = {
      border = "double",
      preview = {
        wo = { number = false, relativenumber = false, signcolumn = 'no' },
      },
      input = {
        keys = {
          ['<PageUp>']   = { 'list_scroll_up', mode   = { 'i', 'n' } },
          ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
      },
    },
  },

  --  ─────── my custom layouts ────────

    -- stylua: ignore 
    layouts = {
      my_default = { -- 2 pane standard
        layout = {
          box    = 'horizontal',
          width  = 0.95,
          height = 0.8,
          {
            box       = 'vertical',
            border    = 'rounded',
            title     = '{source} {live} {flags}',
            title_pos = 'center',
            { win     = 'input', height = 1, border = 'bottom' },
            { win     = 'list', border  = 'none' },
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
            { win     = 'input', height = 1, border = 'bottom' },
            { win     = 'list', border  = 'none' },
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
            { win     = 'input', height = 1, border = 'bottom' },
            { win     = 'list', border  = 'none' },
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
      lsp_symbols     = { layout = { preset = "my_default" } },
      marks           = { layout = { preset = 'default' } },
      qflist          = { layout = { preset = 'my_default' } },
      recent = {
        layout = { preset = "my_default" },
        filter = { cwd = false },
      },
      registers       = { layout = { preset = 'my_default' } },
      search_history  = { layout = { preset = 'my_spelling' } },
      spelling        = { layout = { preset = 'my_spelling' } },
      undo            = { layout = { preset = 'my_default' } },
      zoxide          = { layout = { preset = 'my_keymaps' } },

      -- stylua: ignore 
      explorer = {
       replace_netrw = true, -- Replace netrw with the snacks explorer
        layout = {
          { preview = true },
          layout = {
            box    = 'horizontal',
            height = 0.85,
            width  = 0.90,
            {
              border    = 'rounded',
              box       = 'vertical',
              title     = '{source} {live} {flags}',
              title_pos = 'center',
              { win     = 'input', height = 1, border = 'bottom' },
              { win     = 'list', border  = 'none' },
            },
            { win = 'preview', border = 'rounded', width = 0.65, title = '{preview}' },
          },
        },
        win = {
          list = {
            keys = {
              ['<left>']     = 'explorer_up',
              ['g.']         = 'toggle_hidden',
              ['<PageUp>']   = { 'list_scroll_up', mode   = { 'i', 'n' } },
              ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
            },
          },
        },
        auto_close  = true,
        diagnostics = false,
        follow_file = true,
        formatters = {
          file = { filename_only = true },
          tree = true,
        },
      },
    },
  },

  -- dashboard config

  dashboard = {
    enabled = false,
    width = 45,
    fullscreen = false,
    preset = {
      -- stylua: ignore 
      keys = {
        { icon = '', key = 'c', desc = 'Commands',  action = '<Leader>fc'  },
        -- { icon = '', key = 'e', desc = 'Explorer',  action = '<Leader>fe'  },
        { icon = '', key = 'f', desc = 'Find file', action = '<Leader>ff'  },
        { icon = '', key = 'g', desc = 'Grep',      action = '<Leader>fg'  },
        { icon = '', key = 'j', desc = 'Jumps',     action = '<Leader>fj'  },
        { icon = '', key = 'r', desc = 'Recent',    action = '<Leader>fr'  },
        { icon = '', key = 'z', desc = 'Zoxide',    action = '<Leader>z'   },
      },
    },
  formats = {
      key = function(item)
        return {
          { '[', hl = 'special' },
          { item.key, hl = 'key' },
          { ']', hl = 'special' },
        }
      end,
    },
    sections = {
      { title = "If it ain't broke, don't fix it", align = 'center', padding = 1 },
      { section = 'recent_files', current = true, cwd = false, align = 'left', limit = 9, padding = 1 },
      { section = 'keys', align = 'left', padding = 1 },
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
})

-- --  ────── status column setup ───────
--
-- -- set up for status column to display folds with no numbers
-- -- and proper icons
-- local function _clean_leader(s)
--   s = (s or ''):gsub('^%s*', '')
--   s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
--   return s
-- end
--
-- function _G.MyFoldText()
--   local fs, fe = vim.v.foldstart, vim.v.foldend
--   local count = fe - fs + 1
--
--   local first = vim.fn.getline(fs)
--   local ind_cols = vim.fn.indent(fs)
--
--   local max_indent_cols = 32
--   if ind_cols > max_indent_cols then
--     ind_cols = max_indent_cols
--   end
--
--   local prefix = string.rep(' ', ind_cols)
--   local content = first:match('^%s*(.*)$') or first
--   content = _clean_leader(content)
--
--   local winw = vim.api.nvim_win_get_width(0)
--   local padding = 10
--   local avail = math.max(20, winw - padding - ind_cols)
--
--   local function clip_display(s, w)
--     if vim.fn.strdisplaywidth(s) <= w then
--       return s
--     end
--     local out, used = {}, 0
--     for _, ch in utf8.codes(s) do
--       local c = utf8.char(ch)
--       local cw = vim.fn.strdisplaywidth(c)
--       if used + cw > w then
--         break
--       end
--       table.insert(out, c)
--       used = used + cw
--     end
--     return table.concat(out) .. '…'
--   end
--
--   local preview = clip_display(content, avail)
--   -- set the format of the string at the top of each fold
--   return string.format(' >>>   %s%s  ⋯  [%d]   <<<', prefix, preview, count)
-- end
--
-- vim.opt.foldenable = true
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- vim.opt.foldlevel = 99
-- vim.opt.foldtext = 'v:lua.MyFoldText()'
-- vim.opt.foldcolumn = 'auto:1'
--
-- -- stylua: ignore
-- vim.opt.fillchars:append({
--   foldopen  = '▼',
--   foldclose = '▶',
--   -- fold   = '·',
--   fold      = ' ',
--   foldsep   = ' ',
-- })
--
--  ─────────── end config ───────────

--    ╭────────────────────────────╮
--    │        key mappings        │
--    ╰────────────────────────────╯

--  ──────────── pickers ─────────────

-- Kset('n', '<Leader>sb', '<cmd>lua Snacks.picker.buffers()<cr>', { desc = 'buffers' })
--
-- Kset(
--   'n',
--   '<Leader>sd',
--   '<cmd>lua Snacks.picker.diagnostics_buffer()<cr>',
--   { desc = 'diagnostics - buffer' }
-- )
--
-- Kset(
--   'n',
--   '<Leader>se',
--   '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
--   { desc = 'Explorer' }
-- )
--
-- Kset(
--   'n',
--   '<Leader>x',
--   '<cmd>lua Snacks.explorer({ auto_close = true, include = {"%.md"}, layout = { preset = "sidebar", preview = true } } )<cr>',
--   { desc = 'Explorer' }
-- )
--
-- Kset('n', '<Leader>sj', function()
--   local snacks = require('snacks')
--   snacks.picker({
--     source = 'jumps',
--   })
-- end, { desc = 'jumps' })
--
-- Kset('n', '<Leader>ss', function()
--   local snacks = require('snacks')
--   snacks.picker({
--     source = 'search_history',
--   })
-- end, { desc = 'search history' })
-- Kset('n', '<Leader>sg', '<cmd>lua Snacks.picker.grep()<cr>', { desc = 'grep' })
-- Kset('n', '<Leader>sh', '<cmd>lua Snacks.picker.help()<cr>', { desc = 'help' })
-- Kset(
--   'n',
--   '<Leader>sk',
--   '<cmd>lua Snacks.picker.keymaps({layout = {preview = false}})<cr>',
--   { desc = 'keymaps' }
-- )
-- Kset('n', '<Leader>sl', '<cmd>lua Snacks.picker.lines()<cr>', { desc = 'buffer lines' })
-- Kset('n', '<Leader>sm', '<cmd>lua Snacks.picker.marks()<cr>', { desc = 'marks' })
-- Kset('n', '<Leader>sn', '<cmd>lua Snacks.picker.notifications()<cr>', { desc = 'notifications' })
-- Kset('n', '<Leader>sq', '<cmd>lua Snacks.picker.qflist()<cr>', { desc = 'quick fix' })
-- Kset('n', '<Leader>sR', '<cmd>lua Snacks.picker.registers()<cr>', { desc = 'registers' })
-- Kset('n', '<Leader>su', '<cmd>lua Snacks.picker.undo()<cr>', { desc = 'undo history' })
-- Kset('n', '<Leader>sy', '<cmd>lua Snacks.lazygit.open(opts)<cr>', { desc = 'lazygit' })
--
-- Kset('n', '<Leader>sr', function()
--   vim.cmd('wshada')
--   vim.cmd('rshada!')
--   Snacks.picker.recent({ refresh = true })
-- end, { desc = 'Recent Files (Synced)' })
--
-- Kset(
--   'n',
--   '<Leader>sw',
--   '<cmd>lua Snacks.picker.grep_word()<cr>',
--   { desc = 'grep selection or word' }
-- )
--
-- Kset('n', '<Leader>sz', '<cmd>lua Snacks.zen()<cr>', { desc = 'zen mode' })
-- Kset('n', '<Leader>z', '<cmd>lua Snacks.picker.zoxide()<cr>', { desc = 'Zoxide' })
--
-- Kset('n', '<Leader>]', '<cmd>lua Snacks.dashboard.open()<cr>', { desc = 'Open dashboard' })
--
-- -- Toggle terminal in a centered floating window
-- Kset({ 'n', 't' }, '<Leader>st', function()
--   Snacks.terminal.toggle(nil, {
--     win = {
--       position = 'float',
--       border = 'rounded',
--       width = 0.9,
--       height = 0.9,
--     },
--   })
-- end, { desc = 'toggle floating terminal' })
--
-- -- Spelling picker
-- Kset('n', 'zz', function()
--   require('snacks').picker.spelling({
--     -- layout = 'my_spelling',
--   })
-- end, { desc = 'Spelling Suggestions' })
--
-- -- Command picker
-- Kset('n', '<Leader>sc', function()
--   require('snacks').picker.command_history({
--     layout = 'my_keymaps',
--     preview = false, -- It doesn't have a preview window in the box, so this is safe
--   })
-- end, { desc = 'cmd history' })
--
-- Indent toggle
Kset('n', '<leader>si', function()
  if Snacks.indent.enabled then
    Snacks.indent.disable()
  else
    Snacks.indent.enable()
  end
end, { desc = 'Toggle indent Guides' })
--  ───── 2 pickers with cwd displayed - from ChatGPT ─────

Kset('n', '<Leader>sf', function()
  local snacks = require('snacks')
  snacks.picker({
    source = 'files',
    title = Myfn.short_cwd(),
  })
end, { desc = 'files cwd' })
--
-- Kset('n', '<Leader><space>', function()
--   local snacks = require('snacks')
--   snacks.picker({
--     source = 'files',
--     title = Myfn.short_cwd(),
--   })
-- end, { desc = 'Files cwd' })
--

--  ────────── for deletes ───────────

Kset('n', '<Leader>bd', '<cmd>lua Snacks.bufdelete()<cr>', { desc = 'delete current' })
Kset('n', '<Leader>bo', '<cmd>lua Snacks.bufdelete.other()<cr>', { desc = 'delete other' })
-- Kset('n', '<Leader>ba', '<cmd>lua Snacks.bufdelete.all()<cr>', { desc = 'delete all' })
Kset('n', '<Leader>ba', function()
  Snacks.bufdelete.all()
  Snacks.dashboard.open()
end, { desc = 'delete all' })
