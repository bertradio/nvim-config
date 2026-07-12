--    ╭────────────────────────────╮
--    │          init.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- moved all setting to settings.lua 4/10/26 - only requires here
-- also move all adds to individual file and lazy loadedi with plugin_setup
-- 05/03/26 - added code to configure MiniStarter

-- delete no name buffer when starter starts
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniStarterOpened',
--   callback = function()
--     local bufs = vim.api.nvim_list_bufs()
--     local cur_buf = vim.api.nvim_get_current_buf()
--
--     -- 1. Rename the buffer for the tabline
--     -- Note: We use pcall because Nvim won't let you rename to
--     -- a name that already exists in the buffer list.
--     pcall(vim.api.nvim_buf_set_name, cur_buf, 'Dashboard')
--     for _, bufnr in ipairs(bufs) do
--       -- Check if buffer is empty, unnamed, and not the current starter buffer
--       local name = vim.api.nvim_buf_get_name(bufnr)
--       local is_empty = vim.api.nvim_buf_line_count(bufnr) == 1
--         and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ''
--       local is_no_name = (name == '' or name == nil)
--       local is_not_starter = vim.bo[bufnr].filetype ~= 'ministarter'
--
--       if is_no_name and is_empty and is_not_starter then
--         -- Use pcall to prevent errors if the buffer is already being managed
--         pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
--       end
--     end
--     -- Force the tabline back on for this specific window/buffer
--     vim.cmd('setlocal showtabline=2')
--     -- Tell lualine to wake up and look at the new buffer
--     if package.loaded['lualine'] then
--       local lualine_mod = package.loaded['plg_cfg.lualine']
--       if lualine_mod and type(lualine_mod) == 'table' then
--         lualine_mod.refresh()
--       end
--     end
--   end,
-- })

-- for all keymaps
Kset = vim.keymap.set

-- initialization files
require('settings') -- calls options.lua
require('plugin_setup') -- autocmds to set order of lazy loading
