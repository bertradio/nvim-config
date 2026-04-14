-- snacks-config.lua
-- converted from nvim 0.11 by Gemini
--
-- ============================================================================
--
-- 1. NATIVE PLUGIN LOADING (Neovim 0.12+)
-- ============================================================================
-- This replaces the 'lazy.nvim' table structure.
vim.pack.add({
  { src = 'https://github.com/folke/snacks.nvim' },
  -- You can specify a branch if you're tracking the development version
  -- version = 'main',
})

-- ============================================================================
-- 2. HELPER FUNCTIONS (For Explorer Actions)
-- ============================================================================
local uv = vim.uv or vim.loop

local function is_windows()
  -- If you don't have a 'platform' module, this is a standard Lua check:
  -- return vim.fn.has('win32') == 1
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

local function ends_with_sep(p)
  local sep = path_sep()
  return p:sub(-1) == sep
end

local function is_dirpath_hint(p)
  p = norm_drive_root(p)
  if p == '.' or p == '..' then
    return true
  end
  if ends_with_sep(p) then
    return true
  end
  local st = uv.fs_stat(p)
  if st and st.type == 'directory' then
    return true
  end
  return false
end

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

local function current_entry(picker)
  if picker and picker.list and picker.list.current then
    local ok, item = pcall(function()
      return picker.list:current()
    end)
    if ok and item then
      return item
    end
  end
  local sel = picker and picker:selected() or {}
  return sel and sel[1] or nil
end

-- ============================================================================
-- 3. SNACKS SETUP
-- ============================================================================

local excluded_exts = require('config.file_exclude')

require('snacks').setup({
  bigfile = { enabled = true },
  input = { enabled = true },
  lazygit = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },

  -- for clean status column without numbers and proper fold icons
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

    -- Global settings - applies to Files, Grep, Explorer, etc.
    win = {
      preview = {
        wo = {
          number = false,
          relativenumber = false,
          signcolumn = 'no',
        },
      },
    },

    layouts = {
      my_default = {
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
      my_spelling = {
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
      my_keymaps = {
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

    sources = {
      buffers = { layout = { preset = 'my_default' } },
      command_history = { layout = { preset = 'my_spelling' } },
      files = { layout = { present = 'my_default' } },
      grep = { layout = { preset = 'my_default' } },
      keymaps = { layout = { preset = 'my_keymaps' } },
      lsp_symbols = { layout = { preset = 'default' } },
      marks = { layout = { preset = 'default' } },
      qflist = { layout = { preset = 'my_default' } },
      recent = { layout = { preset = 'my_default' } },
      registers = { layout = { preset = 'my_default' } },
      smart = { layout = { preset = 'my_default' } },
      spelling = { layout = { preset = 'my_spelling' } },
      undo = { layout = { preset = 'my_default' } },
      zoxide = { layout = { preset = 'my_spelling' } },

      -- Explorer configuration
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
            },
          },
        },
        auto_close = true,
        diagnostics = false,
        diagnostics_open = false,
        follow_file = true,
        formatters = {
          git_status_open = false,
          jump = { close = false },
          supports_live = true,
          tree = true,
          watch = true,
          file = { filename_only = true },
          severity = { pos = 'right' },
        },
        actions = {
          safe_copy = function(picker)
            local Actions = require('snacks.explorer.actions')
            local Tree = require('snacks.explorer.tree')

            local sel = picker:selected({ fallback = true })
            if #sel == 0 then
              return
            end

            local srcs = {}
            for _, it in ipairs(sel) do
              table.insert(srcs, Snacks.picker.util.path(it))
            end
            local cwd = (picker.cwd and picker:cwd()) or vim.fn.getcwd()
            local cur = current_entry(picker)
            local cursor_dir = nil
            if cur and cur.file then
              local f = cur.file
              local st = uv.fs_stat(f)
              if st and st.type == 'directory' then
                local same = false
                for _, s in ipairs(srcs) do
                  if s == f then
                    same = true
                    break
                  end
                end
                if not same then
                  cursor_dir = f
                end
              end
            end

            local dest, to_dir
            if cursor_dir then
              dest = cursor_dir
              to_dir = true
            else
              local default_dest = (#srcs == 1)
                  and vim.fs.joinpath(cwd, vim.fn.fnamemodify(srcs[1], ':t'))
                or (cwd .. (path_sep()))
              local dest_in = vim.fn.input({ prompt = 'Copy to: ', default = default_dest })
              if not dest_in or dest_in == '' then
                return
              end
              dest = abspath(dest_in)
              to_dir = is_dirpath_hint(dest)
            end

            local all_yes = false
            for _, src in ipairs(srcs) do
              local target = to_dir and vim.fs.joinpath(dest, vim.fn.fnamemodify(src, ':t')) or dest
              if src == target then
                Snacks.notify.warn('Skipping: Source and destination are the same: ' .. src)
              else
                local src_stat = uv.fs_stat(src)
                if not src_stat then
                  Snacks.notify.error('Cannot access: ' .. src)
                  return
                end
                local exists = uv.fs_stat(target) ~= nil
                local do_overwrite = false
                if exists and not all_yes then
                  local choice = vim.fn.confirm(
                    ('`%s` exists.\nOverwrite?'):format(vim.fn.fnamemodify(target, ':p:~:.')),
                    '&Yes\n&No\n&All\n&Cancel',
                    2
                  )
                  if choice == 1 then
                    do_overwrite = true
                  elseif choice == 3 then
                    do_overwrite = true
                    all_yes = true
                  elseif choice == 4 then
                    return
                  else
                    do_overwrite = false
                  end
                end
                if exists and not (do_overwrite or all_yes) then
                else
                  local ok, err =
                    copy_one(src, target, src_stat.type == 'directory', do_overwrite or all_yes)
                  if not ok then
                    Snacks.notify.error(
                      'Copy failed for: ' .. src .. (err ~= '' and ('\n' .. err) or '')
                    )
                    return
                  end
                end
              end
            end

            picker.list:set_selected()
            Tree:refresh(cwd)
          end,

          safe_move = function(picker)
            local Actions = require('snacks.explorer.actions')
            local Tree = require('snacks.explorer.tree')

            local sel = picker:selected({ fallback = true })
            if #sel == 0 then
              return
            end

            local srcs = {}
            for _, it in ipairs(sel) do
              table.insert(srcs, Snacks.picker.util.path(it))
            end
            local cwd = (picker.cwd and picker:cwd()) or vim.fn.getcwd()
            local cur = current_entry(picker)
            local cursor_dir = nil
            if cur and cur.file then
              local f = cur.file
              local st = uv.fs_stat(f)
              if st and st.type == 'directory' then
                local same = false
                for _, s in ipairs(srcs) do
                  if s == f then
                    same = true
                    break
                  end
                end
                if not same then
                  cursor_dir = f
                end
              end
            end

            local dest, to_dir
            if cursor_dir then
              dest = cursor_dir
              to_dir = true
            else
              local default_dest = (#srcs == 1)
                  and vim.fs.joinpath(cwd, vim.fn.fnamemodify(srcs[1], ':t'))
                or (cwd .. (path_sep()))
              local dest_in = vim.fn.input({ prompt = 'Move to: ', default = default_dest })
              if not dest_in or dest_in == '' then
                return
              end
              dest = abspath(dest_in)
              to_dir = is_dirpath_hint(dest)
            end

            local all_yes = false
            for _, src in ipairs(srcs) do
              local target = to_dir and vim.fs.joinpath(dest, vim.fn.fnamemodify(src, ':t')) or dest
              if src == target then
                Snacks.notify.warn('Skipping: Source and destination are the same: ' .. src)
              else
                local src_stat = uv.fs_stat(src)
                if not src_stat then
                  Snacks.notify.error('Cannot access: ' .. src)
                  return
                end
                local exists = uv.fs_stat(target) ~= nil
                local do_overwrite = false
                if exists and not all_yes then
                  local choice = vim.fn.confirm(
                    ('`%s` exists.\nOverwrite?'):format(vim.fn.fnamemodify(target, ':p:~:.')),
                    '&Yes\n&No\n&All\n&Cancel',
                    2
                  )
                  if choice == 1 then
                    do_overwrite = true
                  elseif choice == 3 then
                    do_overwrite = true
                    all_yes = true
                  elseif choice == 4 then
                    return
                  else
                    do_overwrite = false
                  end
                end
                if exists and not (do_overwrite or all_yes) then
                else
                  local ok, err = move_one(src, target, do_overwrite or all_yes)
                  if not ok then
                    Snacks.notify.error(
                      'Move failed for: ' .. src .. (err ~= '' and ('\n' .. err) or '')
                    )
                    return
                  end
                  Snacks.rename.on_rename_file(src, target)
                end
              end
            end

            picker.list:set_selected()
            Tree:refresh(cwd)
          end,
        },
      },
    },
    matcher = {
      history_bonus = true,
    },
  },
})
