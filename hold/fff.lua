--    ╭────────────────────────────╮
--    │          fff.lua           │
--    ╰────────────────────────────╯

vim.pack.add({ 'https://github.com/dmtrKovalenko/fff.nvim' })

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('fff.nvim')
      end
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
  debug = { enabled = true, show_scores = true },
}

-- all defaults
require('fff').setup({
  base_path = vim.fn.getcwd(),
  prompt = '> ',
  title = 'FFFiles',
  max_results = 100,
  max_threads = 4,
  lazy_sync = true,
  prompt_vim_mode = false,
  layout = {
    height = 1.0,
    width = 0.85,
    prompt_position = 'top', -- or 'top'
    preview_position = 'right', -- 'left' | 'right' | 'top' | 'bottom'
    preview_size = 0.6,
    flex = { size = 80, wrap = 'top' },
    show_scrollbar = true,
    path_shorten_strategy = 'middle_number', -- 'middle_number' | 'middle' | 'end'
    anchor = 'center',
  },
  preview = {
    enabled = true,
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
    cycle_previous_query = '<C-Up>',
    toggle_select = '<Tab>',
    send_to_quickfix = '<C-q>',
    focus_list = '<leader>l',
    focus_preview = '<leader>p',
  },
  frecency = {
    enabled = true,
    db_path = vim.fn.stdpath('cache') .. '/fff_nvim',
  },
  history = {
    enabled = true,
    db_path = vim.fn.stdpath('data') .. '/fff_queries',
    min_combo_count = 3,
    combo_boost_score_multiplier = 100,
  },
  git = {
    status_text_color = true, -- true to color filenames by git status
  },
  grep = {
    max_file_size = 10 * 1024 * 1024,
    max_matches_per_file = 100,
    smart_case = true,
    time_budget_ms = 150,
    modes = { 'plain', 'regex', 'fuzzy' },
    trim_whitespace = false,
  },
  debug = { enabled = false, show_scores = false },
  logging = {
    enabled = true,
    log_file = vim.fn.stdpath('log') .. '/fff.log',
    log_level = 'info',
  },
})

--  ──────────── keymaps ─────────────

Kset('n', 'vf', function()
  require('fff').find_files()
end, { desc = 'FFFind files' })

Kset('n', '<leader>vg', function()
  require('fff').live_grep()
end, { desc = 'LiFFFe grep' })

Kset('n', '<leader>vz', function()
  require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
end, { desc = 'Live fffuzy grep' })

Kset('n', '<leader>vc', function()
  require('fff').live_grep({ query = vim.fn.expand('<cword>') })
end, { desc = 'Search current word' })
