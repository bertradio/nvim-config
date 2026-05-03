--    ╭────────────────────────────╮
--    │        autroups.lua        │
--    ╰────────────────────────────╯

-- code modified by Perplexity for more robustness - 7/8/25
-- adding callbacks and pcall for error trapping

---------- >> Definitions to make code clearer << ---------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

---------- >> Autogroups and Autocommands << ---------------

-- force refresh of shada after save
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('RefreshOldFiles', { clear = true }),
  callback = function()
    -- Force Neovim to register the current file in the shada history
    vim.cmd('wshada')
    -- Optional: Reload the shada to update the internal v:oldfiles list
    vim.cmd('rshada')
  end,
})

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

vim.api.nvim_create_autocmd('BufNewFile', {
  group = grp,
  pattern = '*.sh',
  callback = function()
    read_template('sh.tpl')
  end,
})

vim.api.nvim_create_autocmd('BufNewFile', {
  group = grp,
  pattern = '*.awk',
  callback = function()
    read_template('awk.tpl')
  end,
})

vim.api.nvim_create_autocmd('BufNewFile', {
  group = grp,
  pattern = '*.lua',
  callback = function()
    read_template('lua.tpl')
  end,
})

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

-- disable next line automatic commenting
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove({ 'r', 'o' })
  end,
})

-- comand to delete plugins
-- Simply type :PackDel plugin-name to remove it from disk and the json
vim.api.nvim_create_user_command('PackDel', function(opts)
  local plugin = opts.args
  local ok, err = pcall(function()
    vim.pack.del({ plugin })
  end)

  if ok then
    print('✓ Successfully deleted: ' .. plugin)
  else
    print('✕ Error: ' .. err)
  end
end, {
  nargs = 1,
  -- This adds autocomplete so you can Tab-complete the plugin name
  complete = function()
    return vim.tbl_map(function(p)
      return p.spec.name
    end, vim.pack.get())
  end,
})
