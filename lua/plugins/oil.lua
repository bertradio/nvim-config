-- oil.lua (Final: Imports exclusions + Robust <C-q>)
-- • IMPORTS: Uses 'config.file_exclude' for hidden files (DRY principle).
-- • FIX: <C-q> maps to <cmd>bd!<cr> via string mapping.
-- • FIX: Float borders now correctly turn red (OilBorderDirty) when modified.

-- vim.opt.termguicolors = true
local detail = false

-- =========================
-- Highlights
-- =========================
local CLEAN_BORDER = '#ADD8E6' -- light blue
local DIRTY_BORDER = '#ff5555' -- red
vim.api.nvim_set_hl(0, 'OilBorderClean', { fg = CLEAN_BORDER })
vim.api.nvim_set_hl(0, 'OilBorderDirty', { fg = DIRTY_BORDER })

-- =========================
-- Hidden File Logic
-- =========================
-- 1. Import your glob list (*.zip, *.doc*)
local exclude_globs = require('config.file_exclude')
local hidden_patterns = {}

-- 2. Convert Globs to Lua Patterns
for _, glob in ipairs(exclude_globs) do
  -- Lowercase everything for consistent matching
  local p = glob:lower()
  -- Escape magic chars (dots, hyphens)
  p = p:gsub('%.', '%%.'):gsub('%-', '%%-')
  -- Convert glob * to lua .*
  p = p:gsub('%*', '.*')
  -- Anchor to end of string
  table.insert(hidden_patterns, p .. '$')
end

-- Helpers
local function buf_is_oil_modified(buf)
  return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'oil' and vim.bo[buf].modified
end

-- Apply: floats and normal windows both reflect dirty state
local function apply_oil_window_indicators()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'oil' then
      local is_modified = buf_is_oil_modified(buf)

      -- Logic: If modified, RED. If not, BLUE.
      -- This now applies to BOTH floats and splits equally.
      local border_hl = is_modified and 'OilBorderDirty' or 'OilBorderClean'

      vim.wo[win].winhl = 'FloatBorder:' .. border_hl
      vim.wo[win].winbar = is_modified and ' Oil (modified)' or ''
    end
  end
end

-- Initial + colorscheme
apply_oil_window_indicators()
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  callback = function()
    vim.api.nvim_set_hl(0, 'OilBorderClean', { fg = CLEAN_BORDER })
    vim.api.nvim_set_hl(0, 'OilBorderDirty', { fg = DIRTY_BORDER })
    apply_oil_window_indicators()
  end,
})

-- to enable LSP rename from snacks
vim.api.nvim_create_autocmd('User', {
  pattern = 'OilActionsPost',
  callback = function(event)
    if event.data.actions.type == 'move' then
      Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
    end
  end,
})

-- =========================
-- Plugin spec
-- =========================
return {
  'stevearc/oil.nvim',
  lazy = false,
  opts = {},
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  keys = {
    { '-', '<cmd>Oil .<cr>', desc = 'Oil full screen' },
    {
      '<Leader>-',
      function()
        require('oil').open_float(vim.fn.getcwd(), { preview = {} })
      end,
      desc = 'Oil float (with preview, cwd)',
    },
  },

  config = function()
    -- 1. Create Global Command "OilClose"
    vim.api.nvim_create_user_command('OilClose', function()
      vim.bo.modified = false
      local ok, actions = pcall(require, 'oil.actions')
      if ok and actions.close then
        actions.close.callback()
      else
        vim.api.nvim_win_close(0, true)
      end
    end, { desc = 'Close Oil without saving' })

    require('oil').setup({
      default_file_explorer = true,
      columns = { 'icon' },
      buf_options = { buflisted = false, bufhidden = 'hide' },
      win_options = {
        conceallevel = 3,
        cursorcolumn = false,
        foldcolumn = '0',
        list = false,
        signcolumn = 'no',
        spell = false,
        wrap = true,
      },
      cleanup_delay_ms = 1,
      delete_to_trash = true,
      prompt_save_on_select_new_entry = true,
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
      constrain_cursor = 'name',
      use_default_keymaps = true,

      keymaps = {
        ['.'] = 'actions.tcd',
        ['~'] = 'actions.tcd',
        ['_'] = 'actions.open_cwd',
        ['<BS>'] = 'actions.parent',
        ['<ESC>'] = 'actions.close',
        ['<C-l>'] = 'actions.refresh',
        ['<CR>'] = 'actions.select',
        ['<S-p>'] = 'actions.preview',
        ['g.'] = 'actions.toggle_hidden',
        ['g?'] = 'actions.show_help',
        ['gs'] = 'actions.change_sort',
        ['<C-c>'] = '<cmd>bd!<cr>',
        ['<C-h>'] = 'false',
        ['<C-s>'] = 'false',
        ['<C-t>'] = 'false',
        ['g\\'] = 'false',
        ['gx'] = 'false',

        -- Fix: <C-q> mapped to simple buffer force delete
        ['<C-q>'] = '<cmd>bd!<cr>',

        ['gd'] = {
          desc = 'Toggle file detail view',
          callback = function()
            detail = not detail
            if detail then
              require('oil').set_columns({ 'icon', 'size', 'mtime' })
            else
              require('oil').set_columns({ 'icon' })
            end
          end,
        },
      },

      view_options = {
        case_insensitive = true,
        sort = { { 'type', 'asc' }, { 'name', 'asc' } },
        show_hidden = false,

        -- LOGIC: Checks against the imported patterns
        is_hidden_file = function(name)
          -- 1. Always hide dotfiles
          if vim.startswith(name, '.') then
            return true
          end

          -- 2. Check against the pattern list (case-insensitive)
          local name_lower = name:lower()
          for _, pattern in ipairs(hidden_patterns) do
            if name_lower:match(pattern) then
              return true
            end
          end
          return false
        end,

        is_always_hidden = function()
          return false
        end,
        preview = true,
      },

      float = {
        padding = 3,
        max_width = 0.9,
        max_height = 0,
        border = 'double',
        win_options = { winblend = 0 },
        override = function(conf)
          return conf
        end,
      },

      progress = {
        max_width = 0.8,
        min_width = { 30, 0.4 },
        width = nil,
        max_height = { 10, 0.9 },
        min_height = { 5, 0.1 },
        height = nil,
        border = 'rounded',
        minimized_border = 'none',
        win_options = { winblend = 0 },
      },
    })

    -- Oil-only indicators once buffer exists
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'oil',
      callback = function(ev)
        local win = vim.fn.bufwinid(ev.buf)
        if win ~= -1 then
          apply_oil_window_indicators()
        end
      end,
    })

    -- Update indicators when Oil buffers change
    vim.api.nvim_create_autocmd({ 'BufModifiedSet', 'BufWritePost' }, {
      pattern = 'oil://*',
      callback = function()
        vim.schedule(apply_oil_window_indicators)
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OilActionsPost',
      callback = function()
        vim.schedule(apply_oil_window_indicators)
      end,
    })
    vim.api.nvim_create_autocmd('WinClosed', {
      callback = function()
        vim.schedule(apply_oil_window_indicators)
      end,
    })

    -- Keep Oil in sync with directory changes; safely reopen preview in floats
    vim.api.nvim_create_autocmd('DirChanged', {
      callback = function()
        local ok, oil = pcall(require, 'oil')
        if not ok then
          return
        end
        vim.schedule(function()
          local cwd, curwin = vim.fn.getcwd(), vim.api.nvim_get_current_win()

          local function safe_open_preview(oil_win)
            vim.defer_fn(function()
              if not vim.api.nvim_win_is_valid(oil_win) then
                return
              end
              local ok2, oil2 = pcall(require, 'oil')
              if not ok2 then
                return
              end
              local e = oil2.get_cursor_entry()
              if not e or e.type ~= 'file' then
                return
              end
              pcall(function()
                oil2.open_preview({})
              end)
              if vim.api.nvim_win_is_valid(curwin) then
                vim.api.nvim_set_current_win(curwin)
              end
              apply_oil_window_indicators()
            end, 30)
          end

          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == 'oil' then
                local prev = vim.api.nvim_get_current_win()
                vim.api.nvim_set_current_win(win)
                pcall(oil.open, cwd)

                local cfg = vim.api.nvim_win_get_config(win)
                if cfg and cfg.relative ~= '' then
                  safe_open_preview(win)
                end

                if vim.api.nvim_win_is_valid(prev) then
                  vim.api.nvim_set_current_win(prev)
                end
              end
            end
          end

          if vim.api.nvim_win_is_valid(curwin) then
            vim.api.nvim_set_current_win(curwin)
          end
          apply_oil_window_indicators()
        end)
      end,
    })
  end,
}
