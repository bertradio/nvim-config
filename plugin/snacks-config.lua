--    ╭────────────────────────────╮
--    │     snacks-config.lua      │
--    ╰────────────────────────────╯

-- Updated: Centralized Snacks setup with Notifier - 4-16-26

vim.pack.add({ Gh('folke/snacks.nvim') })

-- ============================================================================
-- 2. HELPER FUNCTIONS (For Explorer Actions)
-- ============================================================================
local uv = vim.uv or vim.loop

local function is_windows()
  return require('platform').is_windows()
end

local function path_sep()
  return is_windows() and '\\' or '/'
end

local function norm_drive_root(p)
  if not is_windows() then
    return p
  end
  local m = p:match('^([A-Za-z]):$')
  if m then
    return m .. ':\\'
  end
  return p
end

--  ──────── unused function ────────

-- local function ends_with_sep(p)
--   local sep = path_sep()
--   return p:sub(-1) == sep
-- end
--
-- local function is_dirpath_hint(p)
--   p = norm_drive_root(p)
--   if p == '.' or p == '..' then
--     return true
--   end
--   if ends_with_sep(p) then
--     return true
--   end
--   local st = uv.fs_stat(p)
--   if st and st.type == 'directory' then
--     return true
--   end
--   return false
-- end

local function abspath(p)
  return norm_drive_root(vim.fn.fnamemodify(p, ':p'))
end

local function ensure_parent_dir(path)
  local parent = vim.fs.dirname(path)
  if parent and parent ~= '' then
    pcall(vim.fn.mkdir, parent, 'p')
  end
end

local function run_cmd(argv)
  if vim.system then
    local res = vim.system(argv, { text = true }):wait()
    return res.code or 0, res.stdout or '', res.stderr or ''
  else
    local esc = {}
    for _, a in ipairs(argv) do
      table.insert(esc, vim.fn.shellescape(a))
    end
    local out = vim.fn.system(table.concat(esc, ' '))
    return vim.v.shell_error, out, ''
  end
end

local function psq(path)
  return "'" .. tostring(path):gsub("'", "''") .. "'"
end

local function copy_one(src, dst, is_dir, overwrite)
  ensure_parent_dir(dst)
  if is_windows() then
    local cmd = { 'powershell.exe', '-NoProfile', '-Command' }
    local force = overwrite and ' -Force' or ''
    local recurse = is_dir and ' -Recurse' or ''
    local inner = ('Copy-Item -LiteralPath %s -Destination %s%s%s -ErrorAction Stop'):format(
      psq(src),
      psq(dst),
      recurse,
      force
    )
    table.insert(cmd, inner)
    local code, _, err = run_cmd(cmd)
    return code == 0, err
  else
    local argv = { 'cp' }
    if is_dir then
      table.insert(argv, '-R')
    end
    table.insert(argv, '-p')
    if overwrite then
      table.insert(argv, '-f')
    end
    table.insert(argv, '--')
    table.insert(argv, src)
    table.insert(argv, dst)
    local code, _, err = run_cmd(argv)
    return code == 0, err
  end
end

local function move_one(src, dst, overwrite)
  ensure_parent_dir(dst)
  if is_windows() then
    local cmd = { 'powershell.exe', '-NoProfile', '-Command' }
    local force = overwrite and ' -Force' or ''
    local inner = ('Move-Item -LiteralPath %s -Destination %s%s -ErrorAction Stop'):format(
      psq(src),
      psq(dst),
      force
    )
    table.insert(cmd, inner)
    local code, _, err = run_cmd(cmd)
    return code == 0, err
  else
    local argv = { 'mv' }
    if overwrite then
      table.insert(argv, '-f')
    end
    table.insert(argv, '--')
    table.insert(argv, src)
    table.insert(argv, dst)
    local code, _, err = run_cmd(argv)
    return code == 0, err
  end
end

--  ──────── unused function ─────────

-- local function current_entry(picker)
--   if picker and picker.list and picker.list.current then
--     local ok, item = pcall(function()
--       return picker.list:current()
--     end)
--     if ok and item then
--       return item
--     end
--   end
--   local sel = picker and picker:selected() or {}
--   return sel and sel[1] or nil
-- end

--  ────────────────────────────────── 3. SNACKS SETUP ──────────────────────────────────

local excluded_exts = require('config.file_exclude')

require('snacks').setup({

  --  ───── Centralized Notification & Progress ─────
  notifier = {
    enabled = true,
    timeout = 3000,
  },

  --  ────── enable other modules ──────
  -- stylua: ignore 
  bigfile      = { enabled = true },
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
              ['c'] = 'safe_copy',
              ['m'] = 'safe_move',
              ['C'] = 'explorer_copy',
              ['M'] = 'explorer_move',
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

        --  ─────── my custom actions ────────

        actions = {

          --  ───── copy with overwrite protection ─────

          safe_copy = function(picker)
            local Tree = require('snacks.explorer.tree')
            local sel = picker:selected({ fallback = true })
            if #sel == 0 then
              return
            end
            local srcs = {}
            for _, it in ipairs(sel) do
              table.insert(srcs, Snacks.picker.util.path(it))
            end
            local cwd = picker:cwd() or vim.fn.getcwd()
            local dest_in = vim.fn.input({ prompt = 'Copy to: ', default = cwd .. path_sep() })
            if not dest_in or dest_in == '' then
              return
            end
            local dest = abspath(dest_in)
            for _, src in ipairs(srcs) do
              copy_one(src, dest, uv.fs_stat(src).type == 'directory', true)
            end
            Tree:refresh(cwd)
          end,

          --  ───── move with overwrite protection ─────

          safe_move = function(picker)
            local Tree = require('snacks.explorer.tree')
            local sel = picker:selected({ fallback = true })
            if #sel == 0 then
              return
            end
            local srcs = {}
            for _, it in ipairs(sel) do
              table.insert(srcs, Snacks.picker.util.path(it))
            end
            local cwd = picker:cwd() or vim.fn.getcwd()
            local dest_in = vim.fn.input({ prompt = 'Move to: ', default = cwd .. path_sep() })
            if not dest_in or dest_in == '' then
              return
            end
            local dest = abspath(dest_in)
            for _, src in ipairs(srcs) do
              move_one(src, dest, true)
              Snacks.rename.on_rename_file(src, dest)
            end
            Tree:refresh(cwd)
          end,
        },
      },
    },
  },
  dashboard = { enabled = false }, -- start with dashboard disabled
})

--  ───── Global override to ensure all plugins use Snacks for notifications ─────

vim.notify = function(msg, level, opts)
  require('snacks').notifier.notify(msg, level, opts)
end
