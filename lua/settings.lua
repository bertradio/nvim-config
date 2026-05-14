--    ╭────────────────────────────╮
--    │        settings.lua        │
--    ╰────────────────────────────╯

-- Optimized for Neovim 0.12
-- General settings and global logic
-- From Gemini. Options moved to options.lua
-- 04/30/26 moved keymaps and aucmds to plugin_setup.lua to load on UI entry

-- 1. PERFORMANCE FIRST
if vim.loader then
  vim.loader.enable()
end

-- 2. LEADERS (Must be set before plugins/keymaps)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Consistent border highlights
vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'Title' })
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })

-- 3. LOAD MODULAR SETTINGS OPTIONS
require('options').setup()

-- 4. DIRECTORY & BINARY LOGIC
do
  local data_dir = vim.fn.stdpath('data')
  vim.fn.mkdir(data_dir .. '/undo', 'p')
  vim.fn.mkdir(data_dir .. '/backup', 'p')
end

Myfn = require('my_fns') -- make my functions accessible

-- shortcut for simpler vim.pack.add to insert github.com
Gh = function(x)
  return 'https://github.com/' .. x
end

--  ──────────────────────────────────────────────────────

-- 6. CUSTOM USER COMMANDS (Logic-heavy)

-- Yazi pathing for Windows
--   if vim.fn.has('win32') == 1 then
--     for _, p in ipairs({ [[C:\Program Files\Yazi]], [[C:\Program Files (x86)\Yazi]] }) do
--       if vim.fn.isdirectory(p) == 1 then
--         Myfn.add_to_vim_path(p)
--         break
--       end
--     end
--   end

-- Sort command
-- vim.api.nvim_create_user_command('Sort', function(opts)
--   if not tonumber(opts.args) then
--     vim.notify('Error: Argument must be a number', vim.log.levels.ERROR)
--     return
--   end
--   local bang = opts.bang and '!' or ''
--   local range = opts.range == 0 and '' or ('%d,%d'):format(opts.line1, opts.line2)
--   local pattern = string.format('%ssort%s /^\\([^|]*|\\)\\{%s\\}/', range, bang, opts.args)
--   vim.cmd(pattern)
-- end, { nargs = 1, bang = true, range = true })
--
-- -- DiffWithSaved command
-- vim.api.nvim_create_user_command('DiffWithSaved', function()
--   local cur_buf = vim.api.nvim_get_current_buf()
--   local filename = vim.api.nvim_buf_get_name(cur_buf)
--   if filename == '' or not vim.fn.filereadable(filename) then
--     vim.notify('File not saved on disk!', vim.log.levels.ERROR)
--     return
--   end
--   local ft = vim.bo.filetype
--   local cur_lines = vim.api.nvim_buf_get_lines(cur_buf, 0, -1, false)
--   local saved_lines = vim.fn.readfile(filename)
--   vim.cmd('tabnew')
--   local function create_scratch_buffer(lines, title)
--     local buf = vim.api.nvim_create_buf(false, true)
--     vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
--     vim.api.nvim_set_option_value('filetype', ft, { buf = buf })
--     vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
--     vim.api.nvim_set_current_buf(buf)
--     vim.api.nvim_set_option_value('winbar', title, { scope = 'local' })
--     return buf
--   end
--   local buf1 = create_scratch_buffer(cur_lines, 'Unsaved changes')
--   vim.cmd('vsplit')
--   local buf2 = create_scratch_buffer(saved_lines, 'File on disk')
--   vim.cmd('windo diffthis')
--   local function close_diff()
--     vim.cmd('tabclose')
--   end
--   vim.keymap.set('n', 'q', close_diff, { buffer = buf1, silent = true })
--   vim.keymap.set('n', 'q', close_diff, { buffer = buf2, silent = true })
-- end, {})
--
-- 7. GUI / NEOVIDE CONFIG
-- if vim.g.neovide then
--   if Myfn.is_windows() then
--     vim.o.guifont = 'JetBrainsMono NFP:h15'
--     vim.g.neovide_remember_window_size = true
--     vim.schedule(function()
--       vim.o.columns, vim.o.lines = 125, 35
--     end)
--   else
--     -- vim.o.guifont = 'JetBrainsMono NFP:h12'
--     vim.o.guifont = 'JetBrainsMono Nerd Font Mono:h12'
--   end
-- end
