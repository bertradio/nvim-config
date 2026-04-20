--    ╭───────────────────────────────────╮
--    │    main setup for mini modules    │
--    ╰───────────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience since small

vim.pack.add({ { src = Gh('nvim-mini/mini.nvim'), branch = 'main' } })

require('mini.ai').setup()

require('mini.align').setup({ mappings = { start = 'ga' } })

require('mini.bracketed').setup()

require('mini.move').setup({
  -- stylua: ignore 
  mappings = {
    left       = '<C-left>',
    right      = '<C-right>',
    down       = '<C-down>',
    up         = '<C-up>',
    line_left  = '<C-left>',
    line_right = '<C-right>',
    line_down  = '<C-down>',
    line_up    = '<C-up>',
  },
})

require('mini.pairs').setup({
  -- add < > as a pair
  mappings = {
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
  },
})

require('mini.surround').setup({
  -- stylua: ignore 
  mappings = {
    add            = 'gza', -- Add surround
    delete         = 'gzd', -- Delete surround
    replace        = 'gzr', -- Replace surround
    find           = 'gzf', -- Find to the right
    find_left      = 'gzF', -- Find to the left
    highlight      = 'gzh', -- Highlight surrounding
    update_n_lines = 'gzn', -- Update n_lines
  },
  n_lines = 50, -- search window for surroundings
})

--  ──────── mini.clue setup ─────────

local miniclue = require('mini.clue')
miniclue.setup({

  window = {
    delay = 500,
    config = {
      width = 'auto',
      border = 'rounded',
    },
    scroll_down = '<Down>',
    scroll_up = '<Up>',
  },

  triggers = {
    { mode = 'c', keys = '<C-r>' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'i', keys = '<C-x>' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '"' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = '<Leader>' },
    { mode = 'n', keys = '`' },
    { mode = 'n', keys = 'g' },
    { mode = 'n', keys = 'z' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '"' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'x', keys = '`' },
    { mode = 'x', keys = 'g' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),

    { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<Leader>e', desc = '+edit configs' },
    { mode = 'n', keys = '<Leader>s', desc = '+snacks' },
  },
})

--  ──────── mini.files setup ────────

-- vim.keymap.set('n', '<Leader>m', '<cmd>lua MiniFiles.open()<cr>', { desc = 'mini.files' })
--
-- require('mini.files').setup({
--   mappings = {
--     -- Map Enter to 'go_in' (acts like L)
--     -- This moves into a directory or opens a file without closing the explorer
--     go_in_plus = '<CR>',
--     -- If you still want the original L behavior, you can leave it or change it
--     -- go_in_plus = '<CR>', -- This is the default; you can change this to something else
--   },
--   content = {
--     -- start with hidden files hidden
--     filter = function(fs_entry)
--       return not vim.startswith(fs_entry.name, '.')
--     end,
--   },
--   -- delete to mini trash: /home/bert/.local/share/nvim/mini.files/trash/
--   options = {
--     permanent_delete = false,
--   },
--   windows = {
--     preview = false,
--     width_preview = 50,
--     max_number = 2,
--   },
-- })
--
-- --  ──────── remap H to <BS> ─────────
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniFilesBufferCreate',
--   callback = function(args)
--     local buf_id = args.data.buf_id
--     -- Remap Backspace to behave like 'h' (go_out)
--     vim.keymap.set('n', '<BS>', 'H', { buffer = buf_id, remap = true, desc = 'Go out' })
--   end,
-- })
--
-- -- set up g. to toggle hidden files
--
-- local show_dotfiles = false -- Start hidden
--
-- local filter_show = function(fs_entry)
--   return true
-- end
-- local filter_hide = function(fs_entry)
--   return not vim.startswith(fs_entry.name, '.')
-- end
--
-- local toggle_dotfiles = function()
--   show_dotfiles = not show_dotfiles
--   local new_filter = show_dotfiles and filter_show or filter_hide
--   require('mini.files').refresh({ content = { filter = new_filter } })
-- end
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniFilesBufferCreate',
--   callback = function(args)
--     vim.keymap.set(
--       'n',
--       'g.',
--       toggle_dotfiles,
--       { buffer = args.data.buf_id, desc = 'Toggle hidden files' }
--     )
--   end,
-- })
--
-- -- 4. Window Styling
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniFilesWindowOpen',
--   callback = function(args)
--     local win_id = args.data.win_id
--     local config = vim.api.nvim_win_get_config(win_id)
--     config.border, config.title_pos = 'double', 'center'
--     vim.api.nvim_win_set_config(win_id, config)
--   end,
-- })
--
-- --  ──────── set up bookmarks ────────
--
-- local set_mark = function(id, path, desc)
--   MiniFiles.set_bookmark(id, path, { desc = desc })
-- end
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniFilesExplorerOpen',
--   callback = function()
--     set_mark('b', '~/bin', 'bin')
--     set_mark('c', '/home/bert/.config/', 'config')
--     set_mark('C', vim.fn.getcwd, 'cwd') -- callable
--     set_mark('d', '~/.Download/', 'downloads')
--     set_mark('h', '/home/bert/.config/nvim/hold/', 'plugin')
--     set_mark('H', '~', 'Home directory')
--     set_mark('l', '/home/bert/.local/', 'local')
--     set_mark('n', '/home/bert/.config/nvim/', 'nvim')
--     set_mark('p', '/home/bert/.config/nvim/plugin/', 'plugin')
--     set_mark('t', '/home/bert/.Temp/', 'temp')
--     set_mark('x', '/home/bert/.local/share/nvim/mini.files/trash/', 'trash')
--     set_mark('y', '/home/bert/.config/yazi', 'yazi')
--   end,
-- })
--
-- --  ───── change cwd to current minifiles dir ─────
--
-- local set_cwd = function()
--   -- Get the path of the entry under the cursor
--   local entry = MiniFiles.get_fs_entry()
--   if entry == nil then
--     return
--   end
--
--   -- Get the directory of that entry
--   local path = entry.path
--   local dir = vim.fn.fnamemodify(path, entry.fs_type == 'file' and ':h' or ':p')
--
--   -- Change Neovim's CWD
--   vim.api.nvim_set_current_dir(dir)
--   vim.notify('CWD changed to: ' .. dir)
-- end
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniFilesBufferCreate',
--   callback = function(args)
--     vim.keymap.set('n', 'gc', set_cwd, { buffer = args.data.buf_id, desc = 'Set CWD' })
--   end,
-- })
