--    ╭────────────────────────────╮
--    │       telescope.lua        │
--    ╰────────────────────────────╯

-- Converted from lazy.nvim to vim.pack 09/06/26

local uv = vim.uv or vim.loop
local is_windows = vim.fn.has('win32') == 1
local has_fzf_toolchain = vim.fn.executable(is_windows and 'cmake' or 'make') == 1

if has_fzf_toolchain then
  local build_group = vim.api.nvim_create_augroup('telescope_fzf_native_build', { clear = true })

  vim.api.nvim_create_autocmd('PackChanged', {
    group = build_group,
    callback = function(event)
      local data = event.data
      if
        data.spec.name ~= 'telescope-fzf-native.nvim'
        or (data.kind ~= 'install' and data.kind ~= 'update')
      then
        return
      end

      local commands = is_windows
          and {
            { 'cmake', '-S', '.', '-B', 'build', '-DCMAKE_BUILD_TYPE=Release' },
            { 'cmake', '--build', 'build', '--config', 'Release' },
            { 'cmake', '--install', 'build', '--prefix', 'build' },
          }
        or {
          { 'make' },
        }

      for _, command in ipairs(commands) do
        local result = vim.system(command, { cwd = data.path }):wait()
        if result.code ~= 0 then
          vim.notify(
            result.stderr,
            vim.log.levels.ERROR,
            { title = 'telescope-fzf-native build failed' }
          )
          break
        end
      end
    end,
  })
end

local plugins = {
  Gh('nvim-lua/plenary.nvim'),
  Gh('nvim-lua/popup.nvim'),
  Gh('stevearc/dressing.nvim'),
  Gh('nvim-telescope/telescope.nvim'),
  Gh('nvim-telescope/telescope-file-browser.nvim'),
  Gh('nvim-telescope/telescope-live-grep-args.nvim'),
  Gh('jvgrootveld/telescope-zoxide'),
}

if has_fzf_toolchain then
  plugins[#plugins + 1] = Gh('nvim-telescope/telescope-fzf-native.nvim')
end

vim.pack.add(plugins)

local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function select_one_or_multi(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    actions.close(prompt_bufnr)
    for _, selection in pairs(multi) do
      if selection.path ~= nil then
        vim.cmd(string.format('%s %s', 'edit', selection.path))
      end
    end
  else
    actions.select_default(prompt_bufnr)
  end
end

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

pcall(telescope.load_extension, 'file_browser')
pcall(telescope.load_extension, 'live_grep_args')
local has_zoxide = pcall(telescope.load_extension, 'zoxide')
local has_fzf = pcall(telescope.load_extension, 'fzf')

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

local map = (rawget(_G, 'Myfn') and Myfn.map) or Kset or vim.keymap.set

-- stylua: ignore
map('n', '<Leader>ab', function() Pick.browser() end, { desc = 'File Browser in cwd' })
map('n', '<Leader>ad', '<cmd>Telescope diagnostics bufnr=0<cr>', { desc = 'Diagnostics' })
map('n', '<Leader>af', function()
  Pick.files()
end, { desc = 'Find files' })
map('n', '<Leader>ag', function()
  Pick.grep()
end, { desc = 'Live grep' })
map('n', '<Leader>ah', function()
  Pick.files({ hidden = true })
end, { desc = 'Find hidden' })
map('n', '<Leader>ao', '<cmd>Telescope oldfiles<cr>', { desc = 'Oldfiles' })
map('n', '<Leader>aq', '<cmd>Telescope quickfix<cr>', { desc = 'Quickfix' })
map('n', '<Leader>as', '<cmd>Telescope search_history<cr>', { desc = 'Search history' })
map('n', '<Leader>at', '<cmd>Telescope<cr>', { desc = 'Telescope cmds' })
map('n', '<Leader>au', '<cmd>Telescope buffers<cr>', { desc = 'Buffers' })
map('n', '<Leader>aw', '<cmd>Telescope grep_string<cr>', { desc = 'Grep word under cursor' })

local function call_zoxide(opts)
  if not has_zoxide or not telescope.extensions.zoxide then
    vim.notify('telescope-zoxide is not loaded.', vim.log.levels.ERROR, { title = 'Telescope' })
    return
  end

  local extension = telescope.extensions.zoxide
  for _, name in ipairs({ 'list', 'zoxide', 'picker' }) do
    if type(extension[name]) == 'function' then
      extension[name](opts or {})
      return
    end
  end

  vim.notify(
    'Cannot find a callable telescope-zoxide picker (tried: list / zoxide / picker).',
    vim.log.levels.ERROR,
    { title = 'Telescope' }
  )
end

local function zoxide_with_keys()
  call_zoxide({
    attach_mappings = function(prompt_bufnr, picker_map)
      local function selected_path()
        local selection = action_state.get_selected_entry()
        return selection and selection.path
      end

      local function change_directory()
        local path = selected_path()
        if path then
          actions.close(prompt_bufnr)
          vim.cmd.cd(path)
        end
      end

      local function find_files()
        local path = selected_path()
        if path then
          actions.close(prompt_bufnr)
          builtin.find_files({ cwd = path })
        end
      end

      local function file_browser()
        local path = selected_path()
        if path then
          actions.close(prompt_bufnr)
          telescope.extensions.file_browser.file_browser({ cwd = path, cwd_to_path = true })
        end
      end

      picker_map('i', '<CR>', change_directory)
      picker_map('n', '<CR>', change_directory)
      picker_map('i', '<C-f>', find_files)
      picker_map('n', '<C-f>', find_files)
      picker_map('i', '<C-b>', file_browser)
      picker_map('n', '<C-b>', file_browser)
      return true
    end,
  })
end

map('n', '<Leader>az', zoxide_with_keys, { desc = 'Zoxide (with <C-f>/<C-b>)' })

vim.api.nvim_create_autocmd('User', {
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    vim.wo.wrap = true
  end,
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
