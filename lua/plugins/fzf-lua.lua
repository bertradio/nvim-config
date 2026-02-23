-- fuzzy finder
-- code from Gemini to incorporate config/exclude_files.lua and hide hidden files

-- stylua: ignore
local function maps()
	Myfn.map('n', '<Leader><space>', '<cmd>FzfLua files<cr>',           { desc = 'find files' })
	Myfn.map('n', '<Leader>fb', '<cmd>FzfLua builtin<cr>',              { desc = 'builtin commands' })
	Myfn.map('n', '<Leader>fc', '<cmd>FzfLua command_history<cr>',      { desc = 'command history' })
	Myfn.map('n', '<Leader>fd', '<cmd>FzfLua diagnostics_document<cr>', { desc = 'diagnostics' })
	Myfn.map('n', '<Leader>ff', '<cmd>FzfLua files<cr>',                { desc = 'find files' })
	Myfn.map('n', '<Leader>fgb', '<cmd>FzfLua grep_curbuf<cr>',         { desc = 'grep curr buff' })
	Myfn.map('n', '<Leader>fgg', '<cmd>FzfLua grep<cr>',                { desc = 'grep' })
	Myfn.map('n', '<Leader>fgw', '<cmd>FzfLua grep_cword<cr>',          { desc = 'grep word' })
	Myfn.map('n', '<Leader>gc', '<cmd>FzfLua git_commits<cr>',          { desc = 'git commits' })
	Myfn.map('n', '<Leader>gs', '<cmd>FzfLua git_status<cr>',           { desc = 'git status' })
	Myfn.map('n', '<Leader>fh', '<cmd>FzfLua helptags<cr>',             { desc = 'helptags' })
	Myfn.map('n', '<Leader>fk', '<cmd>FzfLua keymaps<cr>',              { desc = 'keymaps' })
	Myfn.map('n', '<Leader>fl', '<cmd>FzfLua changes<cr>',              { desc = 'line changes' })
	Myfn.map('n', '<Leader>fm', '<cmd>FzfLua marks<cr>',                { desc = 'marks' })
	Myfn.map('n', '<Leader>fo', '<cmd>FzfLua oldfiles<cr>',             { desc = 'oldfiles' })
	Myfn.map('n', '<Leader>fq', '<cmd>FzfLua quickfix<cr>',             { desc = 'quickfix' })
	Myfn.map('n', '<Leader>fr', '<cmd>FzfLua resume<cr>',               { desc = 'resume' })
	Myfn.map('n', '<Leader>fs', '<cmd>FzfLua spell_suggest<cr>',        { desc = 'spell suggest' })
	Myfn.map('n', 'zz',         '<cmd>FzfLua spell_suggest<cr>',        { desc = 'spell suggest' })
	Myfn.map('n', '<Leader>fu', '<cmd>FzfLua buffers<cr>',              { desc = 'buffers' })
	Myfn.map('n', '<Leader>z', '<cmd>FzfLua zoxide<cr>',                { desc = 'zoxide' })
end

maps()

return {
  'ibhagwan/fzf-lua',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- Global default for all pickers
  defaults = {
    git_icons = true, -- specific to git status (e.g., showing 'M' or icon for modified)
    file_icons = true, -- show the filetype icon (e.g., Lua icon for .lua files)
    color_icons = true, -- colorize the icons
  },

  -- Specific overrides for Git pickers
  git = {
    files = {
      prompt = 'GitFiles❯ ',
      cmd = 'git ls-files --exclude-standard --cached --others',
      git_icons = true, -- show git icons
      file_icons = true, -- show file icons
      color_icons = true, -- colorize file icons
    },
    status = {
      prompt = 'GitStatus❯ ',
      cmd = 'git status -s',
      previewer = 'git_diff',
      file_icons = true,
      git_icons = true,
    },
    commits = {
      prompt = 'Commits❯ ',
      cmd = 'git log --color --pretty=format:"%C(yellow)%h%Creset %C(green)%ad%Creset %s %C(bold blue)<%an>%Creset"',
      preview = 'git show --pretty --stat --color {1}',
    },
    icons = {
      ['M'] = { icon = 'M', color = 'yellow' },
      ['D'] = { icon = 'D', color = 'red' },
      ['A'] = { icon = 'A', color = 'green' },
      ['R'] = { icon = 'R', color = 'yellow' },
      ['C'] = { icon = 'C', color = 'yellow' },
      ['?'] = { icon = '?', color = 'magenta' },
      -- Override these if you want actual Nerd Font icons instead of letters
      -- ['M'] = { icon = '★', color = 'yellow' },
    },
  },

  config = function()
    local fzf = require('fzf-lua')
    local actions = require('fzf-lua.actions')

    -- 1. Load exclude list safely
    -- This expects a file at lua/file_exclude.lua returning a table of strings
    local status, exclude_patterns = pcall(require, 'config.file_exclude')
    if not status then
      -- Fallback if file not found to prevent errors
      exclude_patterns = {}
      vim.notify("fzf-lua: Could not load 'file_exclude.lua'", vim.log.levels.WARN)
    end

    -- 2. Transform the table into an 'fd' compatible string
    local function get_exclude_args()
      local args = ''
      for _, pattern in ipairs(exclude_patterns) do
        -- Wrap pattern in quotes to prevent shell expansion issues
        args = args .. " --exclude '" .. pattern .. "'"
      end
      return args
    end

    fzf.setup({
      -- Load fzf-vim profile defaults first
      'fzf-vim',

      -- Main Files Configuration
      files = {
        -- Explicitly force hidden files OFF at startup
        hidden = false,

        -- Configure the fd command
        -- Note: We add a leading space in the concatenation just to be safe
        fd_opts = '--color=never --type f --follow --exclude .git' .. ' ' .. get_exclude_args(),

        prompt = 'Files ❯ ',
        winopts = { preview = { layout = 'horizontal' } },
        header = false,
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        cwd_prompt = true,
        cwd_prompt_shorten_len = 32,
        cwd_prompt_shorten_val = 1,
        toggle_ignore_flag = '--no-ignore',

        actions = {
          ['default'] = actions.file_edit,
          ['ctrl-s'] = actions.file_split,
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-t'] = actions.file_tabedit,
          ['alt-q'] = actions.file_sel_to_qf,
          ['ctrl-q'] = actions.file_sel_to_qf,
          ['alt-l'] = actions.file_sel_to_ll,
          ['ctrl-h'] = function(_, opts)
            opts.hidden = not opts.hidden
            if opts.hidden then
              vim.notify('Hidden files: ON', vim.log.levels.INFO)
            else
              vim.notify('Hidden files: OFF', vim.log.levels.INFO)
            end
            require('fzf-lua').files(opts)
          end,
        },
      },

      -- Global UI Options
      defaults = { silent = true },
      winopts = {
        height = 0.80,
        width = 0.85,
        row = 0.58,
        col = 0.50,
        border = 'rounded',
        fullscreen = false,
        preview = {
          border = 'border',
          wrap = 'wrap',
          hidden = 'nohidden',
          vertical = 'down:45%',
          horizontal = 'right:65%', -- relative width of preview pane
          layout = 'horizontal',
          flip_columns = 120,
          title = true,
          title_pos = 'center',
          scrollbar = false,
          scrolloff = '-2',
          scrollchars = { '█', '' },
          delay = 100,
          winopts = {
            number = false,
            relativenumber = false,
            cursorline = true,
            cursorlineopt = 'both',
            cursorcolumn = false,
            signcolumn = 'no',
            list = false,
            foldenable = true,
            foldmethod = 'expr',
            delay = 0,
          },
        },
      },

      -- Keymaps
      keymap = {
        builtin = {
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          ['<F3>'] = 'toggle-preview-wrap',
          ['<F4>'] = 'toggle-preview',
          ['<F5>'] = 'toggle-preview-ccw',
          ['<F6>'] = 'toggle-preview-cw',
          ['<S-down>'] = 'preview-page-down',
          ['<S-up>'] = 'preview-page-up',
          ['<S-left>'] = 'preview-page-reset',
        },
        fzf = {
          ['ctrl-z'] = 'abort',
          ['ctrl-u'] = 'unix-line-discard',
          ['ctrl-f'] = 'half-page-down',
          ['ctrl-b'] = 'half-page-up',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['alt-a'] = 'toggle-all',
          ['f3'] = 'toggle-preview-wrap',
          ['f4'] = 'toggle-preview',
          ['shift-down'] = 'preview-page-down',
          ['shift-up'] = 'preview-page-up',
        },
      },
      actions = {
        buffers = {
          ['default'] = actions.buf_edit,
          ['ctrl-s'] = actions.buf_split,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-t'] = actions.buf_tabedit,
        },
      },
      fzf_opts = {
        ['--info'] = 'inline',
        ['--height'] = '100%',
        ['--layout'] = 'reverse',
        ['--border'] = 'none',
        ['--exact'] = '',
      },
      previewers = {
        cat = {
          cmd = 'cat',
          args = '--number',
        },
        bat = {
          cmd = 'bat',
          args = '--color = always --style = numbers,changes',
        },
        head = {
          cmd = 'head',
          args = nil,
        },
        man = {
          cmd = 'man -c %s | col -bx',
        },
        builtin = {
          syntax = true,
          syntax_limit_l = 0,
          syntax_limit_b = 1024 * 1024,
          limit_b = 1024 * 1024 * 10,
          treesitter = { enabled = true, disabled = {} },
          toggle_behavior = 'default',
          extensions = {
            ['svg'] = { 'chafa', '<file>' },
            ['jpg'] = { 'chafa', '<file>' },
            ['png'] = { 'chafa', '<file>' },
          },
        },
      },
      marks = {
        winopts = { preview = { layout = 'vertical' } },
      },
      grep = {
        prompt = 'grep > ',
        input_prompt = 'Grep for ❯ ',
        winopts = { preview = { layout = 'horizontal' } },
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_glob = false,
        glob_flag = '--iglob',
        glob_separator = '%s%-%-',
        no_header = true,
        no_header_i = false,
        actions = {
          ['ctrl-g'] = { actions.grep_lgrep },
        },
        rg_opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e',
        grep_opts = '--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e',
      },
      args = {
        prompt = 'Args ❯ ',
        files_only = true,
        actions = { ['ctrl-x'] = { fn = actions.arg_del, reload = true } },
      },
      oldfiles = {
        prompt = 'Recent ❯ ',
        cwd_only = false,
        winopts = { preview = { layout = 'horizontal' } },
        stat_file = true,
        include_current_session = false,
      },
      buffers = {
        prompt = 'Buffers❯ ',
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        show_unloaded = true,
        cwd_only = false,
        cwd = nil,
        actions = {
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
      },
      tabs = {
        prompt = 'Tabs❯ ',
        tab_title = 'Tab',
        tab_marker = '<<',
        file_icons = true,
        color_icons = true,
        actions = {
          ['default'] = actions.buf_switch,
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
        fzf_opts = {
          ['--delimiter'] = '[\\):]',
          ['--with-nth'] = '2..',
        },
      },
      lines = {
        previewer = 'false',
        prompt = 'Lines❯ ',
        show_unloaded = true,
        show_unlisted = false,
        no_term_buffers = true,
        winopts = { preview = { layout = 'vertical' } },
        fzf_opts = {
          ['--delimiter'] = '[\\]:]',
          ['--nth'] = '2..',
          ['--tiebreak'] = 'index',
          ['--tabstop'] = '1',
        },
        actions = {
          ['default'] = actions.buf_edit_or_qf,
          ['alt-q'] = actions.buf_sel_to_qf,
          ['alt-l'] = actions.buf_sel_to_ll,
        },
      },
      blines = {
        previewer = 'builtin',
        prompt = 'BLines❯ ',
        show_unlisted = true,
        no_term_buffers = false,
        start = 'cursor',
        fzf_opts = {
          ['--delimiter'] = '[\\]:]',
          ['--with-nth'] = '2..',
          ['--tiebreak'] = 'index',
          ['--tabstop'] = '1',
        },
        actions = {
          ['default'] = actions.buf_edit_or_qf,
          ['alt-q'] = actions.buf_sel_to_qf,
          ['alt-l'] = actions.buf_sel_to_ll,
        },
      },
      tags = {
        prompt = 'Tags❯ ',
        ctags_file = nil,
        multiprocess = true,
        file_icons = true,
        git_icons = true,
        color_icons = true,
        no_header = false,
        no_header_i = false,
        rg_opts = '--no-heading --color = always --smart-case',
        grep_opts = '--color = auto --perl-regexp',
        actions = {
          ['ctrl-g'] = { actions.grep_lgrep },
        },
      },
      btags = {
        prompt = 'BTags❯ ',
        ctags_file = nil,
        ctags_autogen = false,
        multiprocess = true,
        file_icons = true,
        git_icons = true,
        color_icons = true,
        rg_opts = '--no-heading --color=always',
        grep_opts = '--color=auto --perl-regexp',
        fzf_opts = {
          ['--delimiter'] = '[\\]:]',
          ['--with-nth'] = '2..',
          ['--tiebreak'] = 'index',
        },
      },
      colorschemes = {
        prompt = 'Colorschemes❯ ',
        live_preview = true,
        actions = { ['default'] = actions.colorscheme },
        winopts = { height = 0.55, width = 0.30 },
      },
      zoxide = {
        prompt = 'zoxide> ',
        winopts = { preview = { layout = 'vertical' } },
        actions = {
          ['default'] = function(selected)
            if not selected or #selected == 0 then
              print('Error: No selection made')
              return
            end
            local dir = selected[1]:match('[^\t]+$')
            dir = dir and dir:gsub('^%s*(.-)%s*$', '%1') or nil
            if dir and vim.fn.isdirectory(dir) == 1 then
              vim.cmd('cd ' .. vim.fn.fnameescape(dir))
              require('fzf-lua').files({ cwd = dir })
            else
              print('Error: Directory not found -', dir)
            end
          end,
        },
      },
      keymaps = {
        prompt = 'Keymaps> ',
        winopts = { preview = { layout = 'vertical' } },
        fzf_opts = { ['--tiebreak'] = 'index' },
        ignore_patterns = { '^<SNR>', '^<Plug>' },
        actions = {
          ['default'] = actions.keymap_apply,
          ['ctrl-s'] = actions.keymap_split,
          ['ctrl-v'] = actions.keymap_vsplit,
          ['ctrl-t'] = actions.keymap_tabedit,
        },
      },
      quickfix = {
        file_icons = true,
        git_icons = true,
      },
      quickfix_stack = {
        prompt = 'Quickfix Stack> ',
        marker = '>',
      },
      lsp = {
        prompt_postfix = '❯ ',
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = true,
        includeDeclaration = true,
        symbols = {
          async_or_timeout = true,
          symbol_style = 1,
          symbol_icons = {
            File = '󰈙',
            Module = '',
            Namespace = '󰦮',
            Package = '',
            Class = '󰆧',
            Method = '󰊕',
            Property = '',
            Field = '',
            Constructor = '',
            Enum = '',
            Interface = '',
            Function = '󰊕',
            Variable = '󰀫',
            Constant = '󰏿',
            String = '',
            Number = '󰎠',
            Boolean = '󰨙',
            Array = '󱡠',
            Object = '',
            Key = '󰌋',
            Null = '󰟢',
            EnumMember = '',
            Struct = '󰆼',
            Event = '',
            Operator = '󰆕',
            TypeParameter = '󰗴',
          },
          symbol_hl = function(s)
            return '@' .. s:lower()
          end,
          symbol_fmt = function(s, opts)
            return '[' .. s .. ']'
          end,
          child_prefix = true,
        },
        code_actions = {
          prompt = 'Code Actions> ',
          async_or_timeout = 5000,
          winopts = {
            row = 0.40,
            height = 0.35,
            width = 0.60,
          },
        },
        finder = {
          prompt = 'LSP Finder> ',
          fzf_opts = { ['--info'] = 'default' },
          file_icons = true,
          color_icons = true,
          git_icons = true,
          async = true,
          silent = true,
          separator = '| ',
          includeDeclaration = true,
          providers = {
            { 'references', prefix = require('fzf-lua').utils.ansi_codes.blue('ref ') },
            { 'definitions', prefix = require('fzf-lua').utils.ansi_codes.green('def ') },
            { 'declarations', prefix = require('fzf-lua').utils.ansi_codes.magenta('decl') },
            { 'typedefs', prefix = require('fzf-lua').utils.ansi_codes.red('tdef') },
            { 'implementations', prefix = require('fzf-lua').utils.ansi_codes.green('impl') },
            { 'incoming_calls', prefix = require('fzf-lua').utils.ansi_codes.cyan('in  ') },
            { 'outgoing_calls', prefix = require('fzf-lua').utils.ansi_codes.yellow('out ') },
          },
        },
      },
      diagnostics = {
        prompt = 'Diagnostics❯ ',
        cwd_only = false,
        file_icons = true,
        git_icons = true,
        diag_icons = true,
        diag_source = true,
        icon_padding = '',
        multiline = true,
      },
      complete_path = {
        cmd = nil,
        complete = { ['default'] = actions.complete },
      },
      complete_file = {
        cmd = nil,
        file_icons = true,
        color_icons = true,
        git_icons = true,
        actions = { ['default'] = actions.complete },
        winopts = { preview = { hidden = 'hidden' } },
      },
      file_icon_colors = {
        ['sh'] = 'green',
      },
      file_icon_padding = '',
    })
  end,
}
