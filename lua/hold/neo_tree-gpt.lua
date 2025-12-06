-- lua/plugins/neo-tree.lua
-- Centered float, inline preview, name-only, tree ≈ 42 cols, stable behavior.

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- optional
    'MunifTanjim/nui.nvim',
  },
  config = function()
    ---------------------------------------------------------------------------
    -- Trash helpers (Windows Recycle Bin + *nix trash)
    ---------------------------------------------------------------------------
    local function is_windows()
      return (vim.loop.os_uname().version or ''):match('Windows') ~= nil
    end
    local function in_wsl()
      local rel = (vim.loop.os_uname().release or ''):lower()
      return rel:find('microsoft') ~= nil or rel:find('wsl') ~= nil
    end
    local function ps_quote(p)
      return "'" .. tostring(p):gsub("'", "''") .. "'"
    end
    local function is_dir(p)
      local s = vim.loop.fs_stat(p)
      return s and s.type == 'directory'
    end
    local function send_to_trash(path)
      if not path or path == '' then
        return false, 'No file selected'
      end
      if is_windows() and not in_wsl() then
        local q = ps_quote(path)
        local cmd = is_dir(path)
            and ([[powershell.exe -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(%s,'OnlyErrorDialogs','SendToRecycleBin')"]]):format(
              q
            )
          or ([[powershell.exe -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(%s,'OnlyErrorDialogs','SendToRecycleBin')"]]):format(
            q
          )
        local out = vim.fn.system(cmd)
        return vim.v.shell_error == 0, out
      else
        local function pick(p)
          if vim.fn.executable('gio') == 1 then
            return 'gio trash -- ' .. vim.fn.fnameescape(p)
          end
          if vim.fn.executable('trash-put') == 1 then
            return 'trash-put -- ' .. vim.fn.fnameescape(p)
          end
          if vim.fn.executable('trash') == 1 then
            return 'trash -- ' .. vim.fn.fnameescape(p)
          end
        end
        local cmd = pick(path)
        if not cmd then
          return false, 'Install gio or trash-cli'
        end
        local out = vim.fn.system(cmd)
        return vim.v.shell_error == 0, out
      end
    end

    ---------------------------------------------------------------------------
    -- Highlights
    ---------------------------------------------------------------------------
    vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { link = 'Comment' })
    pcall(vim.api.nvim_set_hl, 0, 'NeoTreeFloatTitle', { link = 'Normal' })
    pcall(vim.api.nvim_set_hl, 0, 'NeoTreeTitleBar', { link = 'Normal' })

    ---------------------------------------------------------------------------
    -- Sizing math: make the LEFT tree ~42 columns
    ---------------------------------------------------------------------------
    local TREE_COLS = 42 -- your requested name column width
    local PREVIEW_FR = 0.55 -- 55% of float for preview; 45% for tree
    local BORDER_PAD = 4 -- rough padding for borders/padding
    local FLOAT_WIDTH = math.floor(TREE_COLS / (1 - PREVIEW_FR) + BORDER_PAD)
    -- example: 42 / 0.45 + 4 ≈ 97 cols total float width

    ---------------------------------------------------------------------------
    -- Neo-tree setup
    ---------------------------------------------------------------------------
    require('neo-tree').setup({
      bind_to_cwd = true,
      sources = { 'filesystem', 'buffers' },
      enable_diagnostics = false,
      enable_git_status = false,
      enable_preview = true, -- ensure preview system is active

      -- NAME ONLY (no size/mtime/type)
      renderers = {
        directory = { { 'indent' }, { 'icon' }, { 'name' } },
        file = { { 'indent' }, { 'icon' }, { 'name' } },
      },

      default_component_configs = {
        icon = { folder_closed = '', folder_open = '', folder_empty = '' },
        name = {
          trailing_slash = false,
          use_git_status_colors = false,
          highlight_opened_files = 'all',
          -- optional: soft-truncate long names so they stay inside ~42 cols
          truncate_to = TREE_COLS,
          truncate_from = 'right',
        },
        indent = {
          with_markers = true,
          indent_marker = '│',
          last_indent_marker = '└',
          highlight = 'NeoTreeIndentMarker',
          indent_size = 2,
        },
      },

      -------------------------------------------------------------------------
      -- Window: centered float, inline preview (aligned)
      -------------------------------------------------------------------------
      window = {
        position = 'float',
        title = 'Neo-tree',
        title_position = 'center',
        popup = {
          size = { height = '84%', width = FLOAT_WIDTH }, -- explicit cols
          position = { row = '50%', col = '50%' },
          border = { style = 'rounded' },
        },
        preview = {
          position = 'right',
          size = PREVIEW_FR, -- 55% preview
        },
        mappings = {
          ['<space>'] = { 'toggle_node', nowait = true },
          ['<cr>'] = 'open',
          ['l'] = 'open',
          ['h'] = 'close_node',
          -- ["o"] removed per request
          ['s'] = 'open_split',
          ['v'] = 'open_vsplit',
          ['Y'] = 'copy',
          -- Make preview explicit and reliable:
          ['P'] = 'toggle_preview', -- toggle inline preview panel
          ['K'] = 'focus_preview', -- jump cursor into preview
          ['R'] = 'refresh',
          ['.'] = 'toggle_hidden',
          ['<C-c>'] = 'set_root',

          ['d'] = {
            function(state)
              local node = state.tree:get_node()
              local path = node and node:get_id()
              if not path then
                return
              end
              if vim.fn.confirm('Move to Trash?', '&Yes\n&No', 2) ~= 1 then
                return
              end
              local ok, msg = send_to_trash(path)
              if ok then
                vim.notify('Recycled: ' .. path, vim.log.levels.INFO)
                pcall(require('neo-tree.sources.manager').refresh, 'filesystem')
              else
                vim.notify('Failed to recycle: ' .. (msg or ''), vim.log.levels.WARN)
              end
            end,
            desc = 'Send to Trash/Recycle Bin',
          },
          ['D'] = 'delete',
        },
      },

      -- Stable behavior: no auto-follow, watcher off
      filesystem = {
        bind_to_cwd = true,
        sync_root_with_cwd = true,
        hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = false,
        follow_current_file = { enabled = false },
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = { '.DS_Store' },
          never_show = { '.git', 'node_modules', '.cache' },
        },
      },
      buffers = {
        follow_current_file = { enabled = false },
        group_empty_dirs = true,
        show_unloaded = false,
      },

      event_handlers = {
        {
          event = 'file_moved',
          handler = function(a)
            vim.notify(('Moved: %s → %s'):format(a.source, a.destination), vim.log.levels.INFO)
            pcall(require('neo-tree.sources.manager').refresh, 'filesystem')
          end,
        },
        {
          event = 'file_renamed',
          handler = function(a)
            vim.notify(('Renamed: %s → %s'):format(a.source, a.destination), vim.log.levels.INFO)
            pcall(require('neo-tree.sources.manager').refresh, 'filesystem')
          end,
        },
      },
    })

    ---------------------------------------------------------------------------
    -- Safe toggle (float) + manual reveal (since auto-follow is off)
    ---------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>e', function()
      -- Close Telescope if focused (harmless if not present)
      pcall(function()
        local okS, state = pcall(require, 'telescope.actions.state')
        local okA, actions = pcall(require, 'telescope.actions')
        if okS and okA then
          local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
          if picker then
            actions.close(picker.prompt_bufnr or 0)
          end
        end
      end)
      vim.schedule(function()
        require('neo-tree.command').execute({ toggle = true, dir = vim.loop.cwd() })
      end)
    end, { desc = 'Neo-tree: toggle (centered float, inline preview)' })

    vim.keymap.set('n', 'gr', function()
      require('neo-tree.command').execute({ action = 'reveal' })
    end, { desc = 'Neo-tree: reveal current file' })
  end,
}
