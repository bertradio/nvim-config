--    ╭────────────────────────────╮
--    │        fzf-lua.lua         │
--    ╰────────────────────────────╯

-- updated to allow searching AllWords.txt without previewing it
-- changed from lazy to vim.pack 3-30-26
-- replaced snacks because of constant updates

vim.pack.add({
  Gh('nvim-tree/nvim-web-devicons'),
  Gh('ibhagwan/fzf-lua'),
})

local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')

-- Load exclude list safely
local status, exclude_patterns = pcall(require, 'plg_cfg.file_exclude')
if not status then
  exclude_patterns = {}
  vim.notify("fzf-lua: Could not load 'file_exclude.lua'", vim.log.levels.WARN)
end

local function get_exclude_args()
  local args = ''
  for _, pattern in ipairs(exclude_patterns) do
    args = args .. " --exclude '" .. pattern .. "'"
  end
  return args
end

-- stylua: ignore 
fzf.setup({
  'fzf-vim',
  global_python_bin = 'python3',
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
    width      = 0.9,
    preview = {
      border           = 'border',
      delay            = 100,
      flip_columns     = 120,
      hidden           = 'nohidden',
      horizontal       = 'right:65%',
      layout           = 'horizontal',
      preview_max_size = 0.2, -- 200KB limit
      scrollbar        = false,
      scrollchars      = { '█', '' },
      scrolloff        = '-2',
      title            = true,
      title_pos        = 'center',
      vertical         = 'down:45%',
      wrap             = 'wrap',
      winopts = {
        cursorcolumn   = false,
        cursorline     = true,
        cursorlineopt  = 'both',
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
    color_icons            = true,
    cwd_header             = true,
    cwd_prompt             = true,
    cwd_prompt_shorten_len = 32,
    cwd_prompt_shorten_val = 1,
    -- fd_opts                = [[--color = never --type f --hidden --follow --exclude .git]] .. get_exclude_args(),
 fd_opts = '--color=never --type f --follow --exclude .git' .. ' ' .. get_exclude_args(),   file_icons             = true,
    formatter              = 'path.filename_first',
    git_icons              = true,
    header                 = false,
    hidden                 = false,
    multiprocess           = true,
    prompt                 = 'Files ❯ ',
    toggle_ignore_flag     = '--no-ignore',
    winopts                = { preview = { layout = 'horizontal' } },
    -- Define the highlight colors
    highlights = {
      -- set up to dim directory
      -- "FzfLuaDirPart" is the specific group for the directory path
      ['FzfLuaDirPart']  = { link = 'Comment' }, -- Links to 'Comment' (usually dimmed/grey)
      ['FzfLuaFileName'] = { fg   = 'white' }, -- Keeps the filename bright
    },
    actions = {
      ['alt-l']   = actions.file_sel_to_ll,
      ['alt-q']   = actions.file_sel_to_qf,
      ['ctrl-q']  = actions.file_sel_to_qf,
      ['ctrl-s']  = actions.file_split,
      ['ctrl-t']  = actions.file_tabedit,
      ['ctrl-v']  = actions.file_vsplit,
      ['default'] = actions.file_edit,
      ['ctrl-h']  = function(_, opts)
                      opts.hidden = not opts.hidden
                      vim.notify('Hidden files: ' .. (opts.hidden and 'ON' or 'OFF'), vim.log.levels.INFO)
                      require('fzf-lua').files(opts)
                    end,
    },
  },

  previewers = {
    cat     = { cmd = 'cat', args  = '--number' },
    bat     = { cmd = 'bat', args  = '--color = always --style = numbers,changes' },
    head    = { cmd = 'head', args = nil },
    man     = { cmd = 'man -c %s | col -bx' },
    builtin = {
      -- Keeps file in list but disables preview to prevent freezing
      file_ignore_patterns = { 'AllWords.txt', 'Allwords.txt', '*.mem' },
      limit_b              = 1024 * 200,
      syntax               = true,
      syntax_limit_b       = 1024 * 100,
      syntax_limit_l       = 0,
      toggle_behavior      = 'default',
      treesitter           = { enabled = true, disabled = {} },
    },
  },

  -- Restoration of your full Git, Grep, and LSP blocks
  git = {
    files = {
      cmd         = 'git ls-files --exclude-standard --cached --others',
      color_icons = true,
      file_icons  = true,
      git_icons   = true,
      prompt      = 'GitFiles❯ ',
    },
    status = {
      cmd        = 'git status -s',
      file_icons = true,
      git_icons  = true,
      previewer  = 'git_diff',
      prompt     = 'GitStatus❯ ',
    },
    commits = {
      cmd     = 'git log --color --pretty = format:"%C(yellow)%h%Creset %C(green)%ad%Creset %s %C(bold blue)<%an>%Creset"',
      preview = 'git show --pretty --stat --color {1}',
      prompt  = 'Commits❯ ',
    },
  },

  grep = {
    input_prompt = 'Grep for ❯ ',
    multiprocess = true,
    prompt = 'grep > ',
    rg_opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e',
    winopts = { preview = { layout = 'horizontal' } },
    actions = {
      ['alt-l']   = actions.file_sel_to_ll,
      ['alt-q']   = actions.file_sel_to_qf,
      ['ctrl-q']  = actions.file_sel_to_qf,
      ['ctrl-s']  = actions.file_split,
      ['ctrl-t']  = actions.file_tabedit,
      ['ctrl-v']  = actions.file_vsplit,
      ['default'] = actions.file_edit,
      ['ctrl-h']  = function(_, opts)
                      opts.hidden = not opts.hidden
                      vim.notify('Hidden files: ' .. (opts.hidden and 'ON' or 'OFF'), vim.log.levels.INFO)
                      require('fzf-lua').files(opts)
                    end,
    },
  },

  oldfiles = {
    cwd_only                = false,
    include_current_session = true,
    prompt                  = 'Recent ❯ ',
    stat_file               = true,
    winopts                 = { preview = { layout = 'horizontal' } },
  },

  jumps = {
    winopts = { preview = { layout = 'horizontal' } },
  },

  buffers = {
    actions       = { ['ctrl-x'] = { fn = actions.buf_del, reload = true } },
    color_icons   = true,
    file_icons    = true,
    prompt        = 'Buffers❯ ',
    show_unloaded = true,
    sort_lastused = true,
  },
})

-- stylua: ignore
-- set keymaps
local function maps()
  -- Kset('n', '<Leader><space>', '<cmd>FzfLua files<cr>',                { desc = 'find files' })
  Kset('n', '<Leader>fb',      '<cmd>FzfLua buffers<cr>',              { desc = 'buffers' })
  Kset('n', '<Leader>fc',      '<cmd>FzfLua command_history<cr>',      { desc = 'command history' })
  Kset('n', '<Leader>fd',      '<cmd>FzfLua diagnostics_document<cr>', { desc = 'diagnostics' })
  Kset('n', '<Leader>ff',      '<cmd>FzfLua files<cr>',                { desc = 'find files' })
  Kset('n', '<Leader>fg',      '<cmd>FzfLua grep<cr>',                 { desc = 'grep' })
  Kset('n', '<Leader>fh',      '<cmd>FzfLua helptags<cr>',             { desc = 'helptags' })
  Kset('n', '<Leader>fj',      '<cmd>FzfLua jumps<cr>',                { desc = 'jumps' })
  Kset('n', '<Leader>fk',      '<cmd>FzfLua keymaps<cr>',              { desc = 'keymaps' })
  Kset('n', '<Leader>fl',      '<cmd>FzfLua lines<cr>',                { desc = 'line changes' })
  Kset('n', '<Leader>fm',      '<cmd>FzfLua marks<cr>',                { desc = 'marks' })
  Kset('n', '<Leader>fq',      '<cmd>FzfLua quickfix<cr>',             { desc = 'quickfix' })
  Kset('n', '<Leader>fr',      '<cmd>FzfLua oldfiles<cr>',             { desc = 'recent' })
  Kset('n', '<Leader>fs',      '<cmd>FzfLua search_history<cr>',       { desc = 'search history' })
  Kset('n', '<Leader>fu',      '<cmd>FzfLua builtin<cr>',              { desc = 'builtin fzf' })
  Kset('n', 'zz',              '<cmd>FzfLua spell_suggest<cr>',        { desc = 'spell suggest' })

end

-- run keymaps
maps()
