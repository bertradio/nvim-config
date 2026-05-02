--    ╭────────────────────────────╮
--    │          oil.lua           │
--    ╰────────────────────────────╯

-- vim.pack version of old lazy.nvim oil config
-- changed from lazy to vim.pack 3-30-26
-- 04/28/26:
--        simplified code
--        removed indicators of changed oil buffer - no longer worked
--        removed float shortcut
--        Gmini optimized for full-screen and sub-50ms startup

vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
})

local detail = false

-- Pre-compile hidden patterns to save cycles during render
local exclude_globs = require('plg_cfg.file_exclude')
local hidden_patterns = {}
for _, glob in ipairs(exclude_globs) do
  local p = glob:lower():gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%*', '.*')
  table.insert(hidden_patterns, p .. '$')
end

-- LSP rename integration (Snacks)
vim.api.nvim_create_autocmd('User', {
  pattern = 'OilActionsPost',
  callback = function(event)
    if event.data.actions.type == 'move' then
      Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
    end
  end,
})

-- Full-screen toggle oil
vim.keymap.set('n', '-', '<cmd>Oil .<cr>', { desc = 'Oil full screen' })

-- stylua: ignore
require('oil').setup({
  buf_options                   = { buflisted = false, bufhidden = 'hide' },
  columns                       = { 'icon' }, -- Uses web-devicons automatically
  delete_to_trash               = true,
  skip_confirm_for_simple_edits = true,

  -- Rounded border for :w dialogs
  confirmation = {
    border       = 'rounded',
    win_options  = { winblend = 0 },
  },

  win_options = {
    conceallevel = 3,
    signcolumn   = 'no',
    wrap         = true,
  },

  keymaps = {
    ['<ESC>'] = 'actions.close',
    ['<CR>']  = 'actions.select',
    ['<BS>']  = 'actions.parent',
    ['g.']    = 'actions.toggle_hidden',
    ['<C-c>'] = '<cmd>bd!<cr>',
    ['<C-q>'] = '<cmd>bd!<cr>',
    ['gd']    = {
      desc = 'Toggle file detail view',
      callback = function()
        detail = not detail
        require('oil').set_columns(detail and { 'icon', 'size', 'mtime' } or { 'icon' })
      end,
    },
  },

  view_options = {
    case_insensitive = true,
    is_hidden_file   = function(name)
      if vim.startswith(name, '.') then return true end
      local name_lower = name:lower()
      for _, pattern in ipairs(hidden_patterns) do
        if name_lower:match(pattern) then return true end
      end
      return false
    end,
  },
})

-- Optimized Directory Sync (No Float Logic)
vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
          require('oil').open(vim.fn.getcwd())
        end
      end
    end)
  end,
})
