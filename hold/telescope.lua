-- telescope.lua (corrected v4 - resilient zoxide + robust fzf-native)
-- 2025-10-29

local select_one_or_multi = function(prompt_bufnr)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    actions.close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format('%s %s', 'edit', j.path))
      end
    end
  else
    actions.select_default(prompt_bufnr)
  end
end

local uv = vim.uv or vim.loop
local is_windows = vim.fn.has('win32') == 1

-- OS-aware fzf-native dep
local fzf_dep
if is_windows then
  fzf_dep = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    cond = function()
      return vim.fn.executable('cmake') == 1
    end,
  }
else
  fzf_dep = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable('make') == 1
    end,
  }
end

return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    -- Use the widely-used zoxide extension (jvgrootveld). If you prefer lexay's fork, swap here.
    'jvgrootveld/telescope-zoxide',
    'nvim-lua/popup.nvim',
    fzf_dep,
  },

  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    pcall(telescope.load_extension, 'file_browser')
    pcall(telescope.load_extension, 'live_grep_args')
    local has_zoxide = pcall(telescope.load_extension, 'zoxide')
    local has_fzf = pcall(telescope.load_extension, 'fzf')

    -- Helpers that always evaluate cwd at call time
    local Pick = {}
    function Pick.files(opts)
      opts = opts or {}
      opts.cwd = opts.cwd or uv.cwd()
      builtin.find_files(opts)
    end
    function Pick.grep(opts)
      opts = opts or {}
      opts.cwd = opts.cwd or uv.cwd()
      builtin.live_grep(opts)
    end
    function Pick.browser(opts)
      opts = opts or {}
      opts.cwd = opts.cwd or uv.cwd()
      telescope.extensions.file_browser.file_browser(
        vim.tbl_extend('force', { cwd_to_path = true }, opts)
      )
    end

    -- Keymaps
    -- stylua: ignore
    local function maps()
      -- Use your own Myfn.map helper if present; otherwise fallback to vim.keymap.set
      local map = (rawget(_G, 'Myfn') and Myfn.map) or function(mode, lhs, rhs, opts) vim.keymap.set(mode, lhs, rhs, opts) end

      map('n', '<Leader>ab', function() Pick.browser() end, { desc = 'File Browser in cwd' })
      map('n', '<Leader>ad', '<cmd>Telescope diagnostics bufnr=0<cr>', { desc = 'Diagnostics' })
      map('n', '<Leader>af', function() Pick.files() end, { desc = 'Find files' })
      map('n', '<Leader>ag', function() Pick.grep() end,  { desc = 'Live grep' })
      map('n', '<Leader>ah', function() Pick.files({ hidden = true }) end, { desc = 'Find hidden' })
      map('n', '<Leader>ao', '<cmd>Telescope oldfiles<cr>', { desc = 'Oldfiles' })
      map('n', '<Leader>aq', '<cmd>Telescope quickfix<cr>', { desc = 'Quickfix' })
      map('n', '<Leader>as', '<cmd>Telescope search_history<cr>', { desc = 'Search history' })
      map('n', '<Leader>at', '<cmd>Telescope<cr>', { desc = 'Telescope cmds' })
      map('n', '<Leader>au', '<cmd>Telescope buffers<cr>', { desc = 'Buffers' })
      map('n', '<Leader>aw', '<cmd>Telescope grep_string<cr>', { desc = 'Grep word under cursor' })
    end
    maps()

    -- API-agnostic zoxide opener with attach_mappings
    local function call_zoxide(opts)
      if not has_zoxide or not telescope.extensions.zoxide then
        vim.notify(
          "telescope-zoxide not loaded; install 'jvgrootveld/telescope-zoxide' (or your preferred fork).",
          vim.log.levels.ERROR,
          { title = 'Telescope' }
        )
        return
      end
      local ext = telescope.extensions.zoxide
      -- Some variants expose .list, others .zoxide or .picker
      local candidates = { 'list', 'zoxide', 'picker' }
      local fn
      for _, name in ipairs(candidates) do
        if type(ext[name]) == 'function' then
          fn = ext[name]
          break
        end
      end
      if not fn then
        vim.notify(
          'Cannot find a callable picker on telescope-zoxide (tried: list / zoxide / picker).',
          vim.log.levels.ERROR,
          { title = 'Telescope' }
        )
        return
      end
      fn(opts or {})
    end

    local function zoxide_with_keys()
      call_zoxide({
        attach_mappings = function(prompt_bufnr, map)
          -- <CR>: only change directory
          map('i', '<CR>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd.cd(sel.path)
          end)
          map('n', '<CR>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd.cd(sel.path)
          end)
          -- <C-f>: find_files rooted at selection
          map('i', '<C-f>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            builtin.find_files({ cwd = sel.path })
          end)
          map('n', '<C-f>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            builtin.find_files({ cwd = sel.path })
          end)
          -- <C-b>: file_browser rooted at selection
          map('i', '<C-b>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            telescope.extensions.file_browser.file_browser({ cwd = sel.path, cwd_to_path = true })
          end)
          map('n', '<C-b>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            telescope.extensions.file_browser.file_browser({ cwd = sel.path, cwd_to_path = true })
          end)
          return true
        end,
      })
    end

    vim.keymap.set('n', '<Leader>az', zoxide_with_keys, { desc = 'Zoxide (with <C-f>/<C-b>)' })

    -- Autocmd: wrap preview
    vim.api.nvim_create_autocmd('User', {
      pattern = 'TelescopePreviewerLoaded',
      callback = function()
        vim.wo.wrap = true
      end,
    })

    telescope.setup({
      defaults = {
        sorting_strategy = 'ascending',
        dynamic_preview_title = true,
        prompt_prefix = '󰼛 ',
        file_ignore_patterns = {
          '%.JPG$',
          '%.aup3$',
          '%.bin$',
          '%.dll$',
          '%.doc$',
          '%.docx$',
          '%.exe$',
          '%.ico$',
          '%.ini$',
          '%.jpg$',
          '%.json$',
          '%.lnk$',
          '%.lrcat$',
          '%.m4a$',
          '%.mp3$',
          '%.mp4$',
          '%.pdf$',
          '%.png$',
          '%.rdp$',
          '%.url$',
          '%.xcf',
          '%.xls$',
          '%.xlsx$',
          '%.zip$',
        },
        selection_caret = '󱞩 ',
        mappings = { i = { ['<CR>'] = select_one_or_multi } },
        layout_config = {
          horizontal = {
            height = 0.95,
            preview_cutoff = 90,
            prompt_position = 'top',
            width = 0.9,
            preview_width = 0.65,
          },
          bottom_pane = {
            height = 25,
            preview_cutoff = 120,
            dynamic_preview_title = true,
            prompt_position = 'top',
          },
          center = { height = 0.4, preview_cutoff = 40, prompt_position = 'top', width = 0.5 },
          cursor = { height = 0.9, preview_cutoff = 40, width = 0.8, prompt_position = 'top' },
          vertical = { height = 0.9, preview_cutoff = 110, prompt_position = 'top', width = 0.9 },
        },
      },
      pickers = {
        diagnostics = { theme = 'ivy' },
        zoxide = { theme = 'ivy' },
        find_files = { find_command = { 'rg', '--files', '--sort=path', '--max-depth', '3' } },
      },
      extensions = {
        live_grep_args = { auto_quoting = true, theme = 'dropdown' },
        fzf = { case_mode = 'smart_case' },
      },
    })

    if not has_fzf then
      vim.schedule(function()
        vim.notify(
          'telescope-fzf-native.nvim not loaded (no toolchain?). Using default sorters.',
          vim.log.levels.WARN,
          { title = 'Telescope' }
        )
      end)
    end
  end,
}
