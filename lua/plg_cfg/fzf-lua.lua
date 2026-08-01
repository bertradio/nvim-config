--    ╭────────────────────────────╮
--    │        fzf-lua.lua         │
--    ╰────────────────────────────╯

vim.pack.add({
  Gh('nvim-tree/nvim-web-devicons'),
  Gh('ibhagwan/fzf-lua'),
})

local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')

-- Shared extension exclusions used by mini.files and fzf-lua.
-- normally ~/.config/nvim/lua/file_exclude.lua.
local ok, exclude = pcall(require, 'file_exclude')
if not ok then
  exclude = { extensions = {} }
  vim.notify("fzf-lua: could not load 'file_exclude.lua'", vim.log.levels.WARN)
end

-- Keep this separate from file_exclude.show_excluded so toggling fzf-lua
-- does not also change the current mini.files display.
local show_excluded = false

local function sorted_extensions()
  local extensions = {}

  for extension in pairs(exclude.extensions or {}) do
    extensions[#extensions + 1] = extension
  end

  table.sort(extensions)
  return extensions
end

-- Make Linux filename matching case-insensitive without changing fd/rg's
-- matching behavior globally: pdf becomes [pP][dD][fF].
local function case_insensitive_glob(extension)
  return extension:gsub('%a', function(char)
    return string.format('[%s%s]', char:lower(), char:upper())
  end)
end

local function make_fd_opts()
  local opts = '--color=never --type f --follow --exclude .git'

  if not show_excluded then
    for _, extension in ipairs(sorted_extensions()) do
      opts = opts .. string.format(" --exclude '*.%s'", case_insensitive_glob(extension))
    end
  end

  return opts
end

local function make_rg_opts()
  local opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096'

  if not show_excluded then
    for _, extension in ipairs(sorted_extensions()) do
      opts = opts .. string.format(" --glob '!*.%s'", case_insensitive_glob(extension))
    end
  end

  return opts .. ' -e'
end

local function notify_excluded_state()
  vim.notify(
    show_excluded and 'Excluded file types: shown' or 'Excluded file types: hidden',
    vim.log.levels.INFO
  )
end

local function toggle_file_exclusions(_, opts)
  show_excluded = not show_excluded
  notify_excluded_state()

  -- Use only the original call options. The normalized opts table contains
  -- the already-built command, which would preserve the old exclusions.
  local new_opts = vim.deepcopy(opts.__call_opts or {})

  new_opts.fd_opts = make_fd_opts()
  new_opts.query = opts.query

  vim.schedule(function()
    fzf.files(new_opts)
  end)
end

local function toggle_grep_exclusions(_, opts)
  show_excluded = not show_excluded
  notify_excluded_state()

  local new_opts = vim.deepcopy(opts.__call_opts or {})
  new_opts.rg_opts = make_rg_opts()
  new_opts.query = opts.query

  vim.schedule(function()
    fzf.grep(new_opts)
  end)
end

local function toggle_live_grep_exclusions(_, opts)
  show_excluded = not show_excluded
  notify_excluded_state()

  local new_opts = vim.deepcopy(opts.__call_opts or {})
  new_opts.rg_opts = make_rg_opts()
  new_opts.query = opts.query

  vim.schedule(function()
    fzf.live_grep(new_opts)
  end)
end

local function toggle_files_hidden(_, opts)
  opts.hidden = not opts.hidden
  vim.notify('Hidden files: ' .. (opts.hidden and 'ON' or 'OFF'), vim.log.levels.INFO)
  fzf.files(opts)
end

local function toggle_grep_hidden(_, opts)
  opts.hidden = not opts.hidden
  vim.notify('Hidden files: ' .. (opts.hidden and 'ON' or 'OFF'), vim.log.levels.INFO)
  fzf.grep(opts)
end

local function toggle_live_grep_hidden(_, opts)
  opts.hidden = not opts.hidden
  vim.notify('Hidden files: ' .. (opts.hidden and 'ON' or 'OFF'), vim.log.levels.INFO)
  fzf.live_grep(opts)
end

-- stylua: ignore
fzf.setup({
  'fzf-vim',

  defaults = {
    color_icons = true,
    file_icons  = true,
    git_icons   = true,
    silent      = true,
  },

  winopts = {
    border     = 'rounded',
    col        = 0.50,
    fullscreen = false,
    height     = 0.90,
    row        = 0.58,
    width      = 0.90,
    preview = {
      border       = 'border',
      delay        = 200,
      flip_columns = 120,
      hidden       = 'nohidden',
      horizontal   = 'right:65%',
      layout       = 'horizontal',
      scrollbar    = false,
      scrollchars  = { '┃', '' },
      scrolloff    = '-2',
      title        = true,
      title_pos    = 'center',
      vertical     = 'down:45%',
      wrap         = 'wrap',
      winopts = {
        cursorline     = true,
        delay          = 0,
        foldenable     = true,
        foldmethod     = 'expr',
        list           = false,
        number         = false,
        relativenumber = false,
        signcolumn     = 'yes',
      },
    },
  },

  keymap = {
    builtin = {
      ['<F1>']     = 'toggle-help',
      ['<F2>']     = 'toggle-fullscreen',
      ['<F3>']     = 'toggle-preview-wrap',
      ['<F4>']     = 'toggle-preview',
      ['<F5>']     = 'toggle-preview-ccw',
      ['<F6>']     = 'toggle-preview-cw',
      ['<S-down>'] = 'preview-page-down',
      ['<S-up>']   = 'preview-page-up',
      ['<S-left>'] = 'preview-page-reset',
    },
    fzf = {
      ['alt-a']      = 'toggle-all',
      ['ctrl-a']     = 'beginning-of-line',
      ['ctrl-b']     = 'half-page-up',
      ['ctrl-e']     = 'end-of-line',
      ['ctrl-f']     = 'half-page-down',
      ['ctrl-u']     = 'unix-line-discard',
      ['ctrl-z']     = 'abort',
      ['f3']         = 'toggle-preview-wrap',
      ['f4']         = 'toggle-preview',
      ['shift-down'] = 'preview-page-down',
      ['shift-up']   = 'preview-page-up',
    },
  },

  actions = {
    buffers = {
      ['ctrl-s']  = actions.buf_split,
      ['ctrl-t']  = actions.buf_tabedit,
      ['ctrl-v']  = actions.buf_vsplit,
      ['default'] = actions.buf_edit,
    },
  },

  fzf_opts = {
    ['--border'] = 'none',
    ['--exact']  = '',
    ['--height'] = '100%',
    ['--info']   = 'inline',
    ['--layout'] = 'reverse',
  },

  files = {
    cwd_header             = true,
    cwd_prompt             = true,
    cwd_prompt_shorten_len = 32,
    cwd_prompt_shorten_val = 1,
    fd_opts                = make_fd_opts(),
    formatter              = 'path.filename_first',
    header                 = false,
    hidden                 = false,
    multiprocess           = true,
    prompt                 = 'Files ❯ ',
    toggle_ignore_flag     = '--no-ignore',
    winopts                = { preview = { layout = 'horizontal' } },
    highlights = {
      ['FzfLuaDirPart']  = { link = 'Comment' },
      ['FzfLuaFileName'] = { fg = 'white' },
    },
    actions = {
      ['alt-e'] = {
        fn = toggle_file_exclusions,
        header = 'toggle excluded files',
      },
      ['alt-l']   = actions.file_sel_to_ll,
      ['alt-q']   = actions.file_sel_to_qf,
      ['ctrl-h']  = toggle_files_hidden,
      ['ctrl-q']  = actions.file_sel_to_qf,
      ['ctrl-s']  = actions.file_split,
      ['ctrl-t']  = actions.file_tabedit,
      ['ctrl-v']  = actions.file_vsplit,
      ['default'] = actions.file_edit,
    },
  },

  previewers = {
    cat  = { cmd = 'cat', args = '--number' },
    bat  = { cmd = 'bat', args = '--color=always --style=numbers,changes' },
    head = { cmd = 'head', args = nil },
    man  = { cmd = 'man -c %s | col -bx' },
    builtin = {
      -- Keep these files in picker results but do not preview them.
      file_ignore_patterns = { 'AllWords.txt', 'Allwords.txt', '*.mem' },
      limit_b              = 1024 * 200,
      syntax               = true,
      syntax_limit_b       = 1024 * 100,
      syntax_limit_l       = 0,
      toggle_behavior      = 'default',
      treesitter           = { enabled = true, disabled = {} },
    },
  },

  git = {
    files = {
      cmd    = 'git ls-files --exclude-standard --cached --others',
      prompt = 'GitFiles ❯ ',
    },
    status = {
      cmd       = 'git status -s',
      previewer = 'git_diff',
      prompt    = 'GitStatus ❯ ',
    },
    commits = {
      cmd     = 'git log --color --pretty=format:"%C(yellow)%h%Creset %C(green)%ad%Creset %s %C(bold blue)<%an>%Creset"',
      preview = 'git show --pretty --stat --color {1}',
      prompt  = 'Commits ❯ ',
    },
  },

  grep = {
    input_prompt = 'Grep for ❯ ',
    multiprocess = true,
    prompt       = 'Grep ❯ ',
    rg_opts      = make_rg_opts(),
    winopts      = { preview = { layout = 'horizontal' } },
    actions = {
      ['alt-e'] = {
        fn = toggle_grep_exclusions,
        header = 'toggle excluded files',
      },
      ['alt-l']   = actions.file_sel_to_ll,
      ['alt-q']   = actions.file_sel_to_qf,
      ['ctrl-h']  = toggle_grep_hidden,
      ['ctrl-q']  = actions.file_sel_to_qf,
      ['ctrl-s']  = actions.file_split,
      ['ctrl-t']  = actions.file_tabedit,
      ['ctrl-v']  = actions.file_vsplit,
      ['default'] = actions.file_edit,
    },
  },

  oldfiles = {
    cwd_only                = false,
    include_current_session = false,
    ignore_current_buffer   = false,
    stat_file               = true,
    prompt                  = 'Recent ❯ ',
    winopts                 = {
      preview = {
        layout = 'horizontal',
      },
    },
  },

  jumps = {
    winopts = { preview = { layout = 'horizontal' } },
  },

  buffers = {
    actions = {
      ['ctrl-x'] = { fn = actions.buf_del, reload = true },
    },
    ignore_current_buffer = false,
    prompt                = 'Buffers ❯ ',
    show_unloaded         = true,
    sort_lastused         = true,
  },
})

-- stylua: ignore
local function maps()
  -- Kset('n', '<Leader><space>', '<cmd>FzfLua files<cr>',                { desc = 'fzf.findfiles' })
  Kset('n', '<Leader>f.',     '<cmd>FzfLua resume<cr>',                { desc = 'resume last picker' })
  Kset('n', '<Leader>fb',     '<cmd>FzfLua buffers<cr>',               { desc = 'buffers' })
  Kset('n', '<Leader>fc',     '<cmd>FzfLua command_history<cr>',       { desc = 'command history' })
  Kset('n', '<Leader>fd',     '<cmd>FzfLua diagnostics_document<cr>',  { desc = 'diagnostics' })
  Kset('n', '<Leader>fg',     '<cmd>FzfLua grep<cr>',                  { desc = 'grep' })
  Kset('n', '<Leader>fG', function()
    fzf.live_grep({
      actions = {
        ['alt-e']  = toggle_live_grep_exclusions,
        ['ctrl-h'] = toggle_live_grep_hidden,
      },
    })
  end, { desc = 'live grep' })
  Kset('n', '<Leader>fh',     '<cmd>FzfLua helptags<cr>',              { desc = 'helptags' })
  Kset('n', '<Leader>fH',     '<cmd>FzfLua highlights<cr>',            { desc = 'highlights' })
  Kset('n', '<Leader>fi',     '<cmd>FzfLua lsp_implementations<cr>',   { desc = 'lsp implementations' })
  Kset('n', '<Leader>fj',     '<cmd>FzfLua jumps<cr>',                 { desc = 'jumps' })
  Kset('n', '<Leader>fk',     '<cmd>FzfLua keymaps<cr>',               { desc = 'keymaps' })
  Kset('n', '<Leader>fl',     '<cmd>FzfLua lines<cr>',                 { desc = 'lines' })
  Kset('n', '<Leader>fm',     '<cmd>FzfLua marks<cr>',                 { desc = 'marks' })
  Kset('n', '<Leader>fo',     '<cmd>FzfLua lsp_document_symbols<cr>',  { desc = 'document symbols' })
  Kset('n', '<Leader>fO',     '<cmd>FzfLua lsp_workspace_symbols<cr>', { desc = 'workspace symbols' })
  Kset('n', '<Leader>fq',     '<cmd>FzfLua quickfix<cr>',              { desc = 'quickfix' })
  Kset('n', '<Leader>fr',     '<cmd>FzfLua registers<cr>',             { desc = 'registers' })
  Kset('n', '<Leader>fR',     '<cmd>FzfLua lsp_references<cr>',        { desc = 'lsp references' })
  Kset('n', '<Leader>fs',     '<cmd>FzfLua search_history<cr>',        { desc = 'search history' })
  Kset('n', '<Leader>fu',     '<cmd>FzfLua builtin<cr>',               { desc = 'builtin fzf' })
  Kset('n', '<Leader>fw',     '<cmd>FzfLua grep_cword<cr>',            { desc = 'grep word under cursor' })
  Kset('n', '<Leader>fW',     '<cmd>FzfLua grep_cWORD<cr>',            { desc = 'grep WORD under cursor' })
  Kset('n', '<Leader>fx',     '<cmd>FzfLua changes<cr>',               { desc = 'changes' })
  Kset('n', 'zz',             '<cmd>FzfLua spell_suggest<cr>',         { desc = 'spell suggest' })

  Kset('n', '<Leader>fn', function()
    fzf.files({
      cwd = vim.fn.stdpath('config'),
      prompt = 'Neovim ❯ ',
    })
  end, { desc = 'Neovim config' })

  -- recent with no preview - to see paths
  -- Kset('n', '<leader>]', function()
  --   fzf.oldfiles({
  --     winopts = {
  --           preview = {
  --             hidden = true,
  --           },
  --     },
  --   })
  -- end, {desc = 'recent',})

end

maps()
