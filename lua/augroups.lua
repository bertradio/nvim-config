-- code modified by Perplexity for more robustness - 7/8/25
-- adding callbacks and pcall for error trapping

---------- >> Definitions to make code clearer << ---------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

---------- >> To set initial working directory << ---------------

local dir = vim.fn.stdpath('config') .. '/lua/plugins/'

augroup('Set_Directory', { clear = true })
autocmd({ 'VimEnter' }, {
  group = 'Set_Directory',
  pattern = '*',
  command = 'cd! ' .. dir,
})

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
autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter' }, {
  group = 'Set_Cursorline',
  pattern = '*',
  command = 'highlight CursorLine cterm=bold ctermbg=darkgrey ctermfg=white',
})

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
autocmd({ 'WinLeave' }, {
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

---------- >> For Filetype Templates << ---------------

local skeleton_path = vim.fn.stdpath('config') .. '/skeletons/'

augroup('Filetype_Settings', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = 'Filetype_Settings',
  pattern = 'sh',
  callback = function()
    local ok, err = pcall(function()
      if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        local skeleton = skeleton_path .. 'sh.tpl'
        vim.cmd('0r ' .. skeleton)
      end
    end)
    if not ok then
      vim.notify('Error inserting sh skeleton: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = 'Filetype_Settings',
  pattern = 'awk',
  callback = function()
    local ok, err = pcall(function()
      if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        local skeleton = skeleton_path .. 'awk.tpl'
        vim.cmd('0r ' .. skeleton)
      end
    end)
    if not ok then
      vim.notify('Error inserting awk skeleton: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = 'Filetype_Settings',
  pattern = 'lua',
  callback = function()
    local ok, err = pcall(function()
      if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        local skeleton = skeleton_path .. 'lua.tpl'
        vim.cmd('0r ' .. skeleton)
      end
    end)
    if not ok then
      vim.notify('Error inserting lua skeleton: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

-- doe replacements in templates code from Perplexity
vim.cmd(string.format(
  [[
augroup template_replace
  autocmd!
  autocmd BufNewFile *.sh 0r %ssh.tpl | %%s#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
  autocmd BufNewFile *.awk 0r %sawk.tpl | %%s#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
  autocmd BufNewFile *.lua 0r %slua.tpl | %%s#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
augroup END
]],
  skeleton_path,
  skeleton_path,
  skeleton_path
))

---------- >> Set up folding for markdown  << ---------------

-- this code from ChatGPT seems more reliable
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.MarkdownFold(v:lnum)'
    vim.opt_local.foldlevel = 9
  end,
})

function _G.MarkdownFold(lnum)
  local line = vim.fn.getline(lnum)
  local _, hashes = string.find(line, '^(#+) ')
  if hashes then
    return '>' .. hashes
  end
  return '='
end

---------- >> Open buffers at last location (protected) << ---------------

vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*' },
  desc = 'When editing a file, always jump to the last known cursor position',
  callback = function()
    local ok, err = pcall(function()
      local line = vim.fn.line('\'"')
      if
        line >= 1
        and line <= vim.fn.line('$')
        and vim.bo.filetype ~= 'commit'
        and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1
      then
        vim.cmd('normal! g`"')
      end
    end)
    if not ok then
      vim.notify('Error restoring last cursor position: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
})

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
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
    end
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldlevelstart = 99
  end,
})

-- create command to print from neovim in Windows
vim.api.nvim_create_user_command('PrintFile', function()
  if vim.fn.has('win32') == 1 then
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
