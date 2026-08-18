-- Package name changed from `fff.nvim` to `fff`. If you installed fff.nvim before, clean with `:packdel fff.nvim`
vim.pack.add({ 'https://github.com/dmtrKovalenko/fff' })

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('fff')
      end
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
  debug = { enabled = true, show_scores = true },
}

local fff = require('fff')

fff.setup({
  base_path = vim.fn.getcwd(),
  prompt = '> ',
  title = 'FFFiles',
  max_results = 100,
  max_threads = 4,
  lazy_sync = true,
  prompt_vim_mode = false,
  follow_symlinks = false,
  -- Allow indexing the user's $HOME directory. Enabled by default.
  -- Disable if you strictly sure you don't want this, as it makes whole fff error hard
  enable_home_dir_scanning = true,
  -- Allow indexing a filesystem root (e.g. `/`, `C:\`). Disabled by default
  enable_fs_root_scanning = false,
  layout = {
    height = 0.8,
    width = 0.8,
    prompt_position = 'top', -- top or bottom
    preview_position = 'bottom', -- 'left' | 'right' | 'top' | 'bottom'
    preview_size = 0.4,
    -- Border style for the picker windows. Leave unset (nil) to follow the
    -- global `vim.o.winborder`; set it to override fff's borders independently.
    border = nil, -- 'single' | 'double' | 'rounded' | 'solid' | 'shadow' | 'none'
    -- border = {
    --   { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    --   { ' ', ' ', ' ', ' ', ' ' },
    -- },

    flex = { size = 130, wrap = 'top' },
    min_list_height = 10, --  do not display anything except the list below this threshold
    show_scrollbar = true,
    path_shorten_strategy = 'middle_number', -- 'middle_number' | 'middle' | 'end' | 'start'
    anchor = 'center',
  },
  preview = {
    enabled = false,
    max_size = 10 * 1024 * 1024,
    chunk_size = 8192,
    binary_file_threshold = 1024,
    imagemagick_info_format_str = '%m: %wx%h, %[colorspace], %q-bit',
    line_numbers = false,
    cursorlineopt = 'both',
    wrap_lines = false,
    filetypes = {
      svg = { wrap_lines = true },
      markdown = { wrap_lines = true },
      text = { wrap_lines = true },
    },
  },
  keymaps = {
    close = '<Esc>',
    select = '<CR>',
    select_split = '<C-s>',
    select_vsplit = '<C-v>',
    select_tab = '<C-t>',
    move_up = { '<Up>', '<C-p>' },
    move_down = { '<Down>', '<C-n>' },
    preview_scroll_up = '<C-u>',
    preview_scroll_down = '<C-d>',
    toggle_debug = '<F2>',
    cycle_grep_modes = '<S-Tab>',
    insert_newline_escape = '<C-CR>',
    -- grep mode only: jump cursor to first match of next/prev file group
    grep_jump_to_next_file = { '<C-A-n>', '<A-Down>' },
    grep_jump_to_prev_file = { '<C-A-p>', '<A-Up>' },
    cycle_previous_query = '<C-Up>',
    toggle_select = '<Tab>',
    send_to_quickfix = '<C-q>',
    focus_list = '<leader>l',
    focus_preview = '<leader>p',
  },
  frecency = {
    enabled = false,
    db_path = vim.fn.stdpath('cache') .. '/fff_nvim',
  },
  history = {
    enabled = true,
    db_path = vim.fn.stdpath('data') .. '/fff_queries',
    min_combo_count = 3,
    combo_boost_score_multiplier = 100,
  },
  git = {
    status_text_color = false, -- true to color filenames by git status
  },
  file_picker = {
    fuzzy_query_highlighting = false, -- true to highlight fuzzy query matches in file picker results
  },
  select = {
    -- Return winid to open the chosen file in, or nil to open in the original window
    select_window = function(current_buf, action) --[[ default impl ]]
    end,
  },
  grep = {
    max_file_size = 10 * 1024 * 1024,
    max_matches_per_file = 100,
    smart_case = true,
    time_budget_ms = 150,
    modes = { 'plain', 'regex', 'fuzzy' },
    trim_whitespace = false,
    enable_filename_constraint = false, -- treat filename-like tokens (e.g. `score.rs`) in a grep query as a file-path filter scoping the search; off = searched as literal text
    location_format = ':%d:%d', -- printf format for line:col prefix in grep results, e.g. ':%d' for line-only
  },
})

Kset('n', 'ff', function()
  fff.find_files()
end, { desc = 'FFFind files' })
