--    ╭────────────────────────────╮
--    │        autcmds.lua         │
--    ╰────────────────────────────╯

-- code modified by Perplexity for more robustness - 7/8/25
-- adding callbacks and pcall for error trapping
-- 05/10/26 - changed name from autogroups to aucmds

---------- >> Definitions to make code clearer << ---------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

---------- >> Autogroups and Autocommands << ---------------

-- need different functions for file name in Win and Linux
if Myfn.is_windows() then
  -- Make new meaningful backup name, such as filename@2015-04-05_14:59:25i
  -- Code from ChatGPT
  local function get_filename()
    local date_format = '%Y-%m-%d_%H-%M-%S' -- Example: 2025-02-27_10-30-45
    local filename = vim.fn.strftime(date_format)
    filename = filename:gsub(':', '-') -- Replace invalid Windows characters
    return filename
  end
  local group = vim.api.nvim_create_augroup('Set_Backup_Name', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    pattern = '*', -- Match all files
    callback = function()
      vim.opt.backupext = '@' .. get_filename()
    end,
  })
else -- for Linux
  -- Make new meaningful backup name, such as filename@2015-04-05_14:59:25i
  augroup('Set_Backup_Name', { clear = true })
  autocmd('BufWritePre', {
    group = 'Set_Backup_Name',
    pattern = '*',
    command = "let &bex = '@' . strftime('%F_%H:%M:%S')",
  })
end

---------- >> Cursorline << ---------------

augroup('Set_Cursorline', { clear = true })

-- set color of cursorline
-- autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter' }, {
--   group = 'Set_Cursorline',
--   pattern = '*',
--   command = 'highlight CursorLine cterm=bold ctermbg=darkgrey ctermfg=white',
-- })

-- turn on cursorline and set colors in active window
autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter' }, {
  group = 'Set_Cursorline',
  pattern = '*',
  callback = function()
    local ok, err = pcall(function()
      vim.opt_local.cursorline = true
    end)
    if not ok then
      vim.notify('Error setting cursorline: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

-- turn off cursorline in inactive windows
autocmd('WinLeave', {
  group = 'Set_Cursorline',
  pattern = '*',
  callback = function()
    local ok, err = pcall(function()
      vim.opt_local.cursorline = false
    end)
    if not ok then
      vim.notify('Error unsetting cursorline: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

--  ──────── set up templates ────────

local skeleton_path = vim.fn.stdpath('config') .. '/skeletons/'

local function read_template(tpl)
  local file = vim.fs.normalize(skeleton_path .. tpl) -- handles \ vs /
  -- :read needs fnameescape for spaces etc.
  vim.cmd(('0read %s'):format(vim.fn.fnameescape(file)))

  -- Evaluate [:VIM_EVAL:]...[:END_EVAL:] blocks
  vim.cmd([[
    silent! %s#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
  ]])
end

local grp = vim.api.nvim_create_augroup('template_replace', { clear = true })

-- set up templates for various languages

local function init_skeleton(pattern, tpl)
  vim.api.nvim_create_autocmd('BufNewFile', {
    group = grp,
    pattern = pattern,
    callback = function()
      read_template(tpl)
    end,
  })
end

init_skeleton('*.sh', 'sh.tpl')
init_skeleton('*.lua', 'lua.tpl')
init_skeleton('*.awk', 'awk.tpl')

---------- >> Remove Windows newlines in Windows << ---------------
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*' },
  callback = function()
    if Myfn.is_windows() then
      local ok, err = pcall(function()
        vim.cmd(':%s/\\r//e')
      end)
      if not ok then
        vim.notify('Error removing Windows newlines: ' .. tostring(err), vim.log.levels.WARN)
      end
    end
  end,
})

-- Markdown: use Treesitter foldexpr (handles sibling headers correctly)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    if vim.fn.has('nvim-0.10') == 1 then
      vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    else
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldlevelstart = 99
    vim.cmd('set ft=markdown')
  end,
})

-- create command to print from neovim in Windows
vim.api.nvim_create_user_command('PrintFile', function()
  if Myfn.is_windows() == 1 then
    vim.cmd('!notepad /p %')
  else
    vim.cmd('!lpr %')
  end
end, {})

-- always restore cursor when returning from ! command
vim.api.nvim_create_autocmd({ 'ShellCmdPost' }, {
  callback = function()
    local gc = vim.o.guicursor
    vim.defer_fn(function()
      vim.o.guicursor = ''
      vim.cmd('redraw!')
      vim.o.guicursor = gc
    end, 50) -- 50ms
  end,
})

-- disable next line automatic commenting
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions = 'jcql'
  end,
})

-- for zsh file proper syntax display
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'zsh',
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = 'zsh'
  end,
})

--  ───── highlight and blink on yank - from ChatFPT ─────

local yank_timeout = 1000

local grp1 = vim.api.nvim_create_augroup('YankHighlight', {
  clear = true,
})

local function set_yank_highlight()
  vim.api.nvim_set_hl(0, 'YankHighlight', {
    fg = '#1e1e2e',
    bg = '#a6e3a1', -- Mocha green
    bold = true,
    nocombine = true,
  })
end

set_yank_highlight()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = grp1,
  desc = 'Restore yank highlight color',
  callback = set_yank_highlight,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = grp1,
  desc = 'Highlight and report yanked text',
  callback = function()
    if vim.v.event.operator ~= 'y' then
      return
    end

    local win = vim.api.nvim_get_current_win()
    local cursorline_was_enabled = vim.wo[win].cursorline

    -- Remove CursorLine before applying the yank highlight.
    vim.wo[win].cursorline = false
    vim.cmd.redraw()

    vim.hl.hl_op({
      higroup = 'YankHighlight',
      timeout = yank_timeout,
      on_visual = true,
    })

    -- Restore this window's previous CursorLine setting afterward.
    vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.wo[win].cursorline = cursorline_was_enabled
        vim.cmd.redraw()
      end
    end, yank_timeout + 50)

    local count = #vim.v.event.regcontents
    local label = count == 1 and 'line' or 'lines'

    vim.notify(string.format('%d %s yanked', count, label), vim.log.levels.INFO)
  end,
})
