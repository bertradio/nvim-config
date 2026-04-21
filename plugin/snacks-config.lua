--    ╭────────────────────────────╮
--    │     snacks-config.lua      │
--    ╰────────────────────────────╯

-- Explorer: Removed custom copy and move actions since they did not seem stable
-- Just using noice

vim.pack.add({ Gh('folke/snacks.nvim') })

local excluded_exts = require('config.file_exclude')

require('snacks').setup({

  --  ────── enable other modules ──────

  bigfile = { enabled = true },
  explorer = { enabled = true },
  input = { enabled = true },
  lazygit = { enabled = true },
  lsp_progress = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },

  -- dashboard config
  dashboard = {
    enabled = false,
    width = 45,
    preset = {
      -- stylua: ignore 
      keys = {
        { icon = '', key = 'e', desc = 'Explorer', action  = '<Leader>se' },
        { icon = '', key = 'f', desc = 'Find file', action = '<Leader>sf' },
        { icon = '', key = 'r', desc = 'Recent', action    = '<Leader>so' },
        { icon = '', key = 'g', desc = 'Grep', action      = '<Leader>sg' },
        { icon = '', key = 'y', desc = 'Yazi', action      = '<Leader>y' },
        { icon = '', key = 'z', desc = 'Zoxide', action    = '<Leader>z' },
      },
      header = [[]],
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
      { title = "\nIf it ain't broke, don't fix it", align = 'center', padding = 1 },
      { section = 'recent_files', align = 'left', limit = 10, padding = 1 },
      { section = 'keys', align = 'left', padding = 1 },
    },
  },

  indent = {
    enabled = false,
    only_current = false,
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

  -- stylua: ignore 
  picker = {
    enabled      = true,
    layout       = "my_default",
    prompt       = '> ',
    ui_select    = true,
    -- exclude      = excluded_exts,
    win = {
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
      lsp_symbols     = { layout = { preset = 'default' } },
      marks           = { layout = { preset = 'default' } },
      qflist          = { layout = { preset = 'my_default' } },
      recent          = { layout = { preset = 'my_default' } },
      registers       = { layout = { preset = 'my_default' } },
      search_history  = { layout = { preset = 'my_spelling' } },
      spelling        = { layout = { preset = 'my_spelling' } },
      undo            = { layout = { preset = 'my_default' } },
      zoxide          = { layout = { preset = 'my_keymaps' } },

      -- stylua: ignore 
      explorer = {
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
})

--  ────── status column setup ───────

-- set up for status column to display folds with no numbers
-- and proper icons

local function _clean_leader(s)
  s = (s or ''):gsub('^%s*', '')
  s = s:gsub('^([%-%*#;/%%!]+)%s*', '')
  return s
end

function _G.MyFoldText()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local count = fe - fs + 1

  local first = vim.fn.getline(fs)
  local ind_cols = vim.fn.indent(fs)

  local max_indent_cols = 32
  if ind_cols > max_indent_cols then
    ind_cols = max_indent_cols
  end

  local prefix = string.rep(' ', ind_cols)
  local content = first:match('^%s*(.*)$') or first
  content = _clean_leader(content)

  local winw = vim.api.nvim_win_get_width(0)
  local padding = 10
  local avail = math.max(20, winw - padding - ind_cols)

  local function clip_display(s, w)
    if vim.fn.strdisplaywidth(s) <= w then
      return s
    end
    local out, used = {}, 0
    for _, ch in utf8.codes(s) do
      local c = utf8.char(ch)
      local cw = vim.fn.strdisplaywidth(c)
      if used + cw > w then
        break
      end
      table.insert(out, c)
      used = used + cw
    end
    return table.concat(out) .. '…'
  end

  local preview = clip_display(content, avail)
  return string.format('%s%s  ⋯  [%d]', prefix, preview, count)
end

vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldtext = 'v:lua.MyFoldText()'
vim.opt.foldcolumn = 'auto:1'

-- stylua: ignore 
vim.opt.fillchars:append({
  foldopen  = '▼',
  foldclose = '▶',
  -- fold   = '·',
  fold      = ' ',
  foldsep   = ' ',
})
