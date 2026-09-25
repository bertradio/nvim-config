--    ╭────────────────────────────╮
--    │          oil.lua           │
--    ╰────────────────────────────╯

-- vim.pack version of old lazy.nvim oil config
-- changed from lazy to vim.pack 3-30-26
-- 04/28/26:
--        simplified code
--        removed indicators of changed oil buffer - no longer worked
--        removed float shortcut
--        Gmini optimized for full-screen and quick startup

vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
})

local detail = false

-- Pre-compile hidden patterns to save cycles during render
-- local exclude_globs = require('plg_cfg.file_exclude')
local exclude_globs = {}
local hidden_patterns = {}
for _, glob in ipairs(exclude_globs) do
  local p = glob:lower():gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%*', '.*')
  table.insert(hidden_patterns, p .. '$')
end

-- Keymap to Start oil
Kset('n', '=', '<cmd>Oil .<cr>', { desc = 'Oil full screen' })

-- set up oil
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
    ['q']     = 'actions.close',
    ['<CR>']  = 'actions.select',
    ['<BS>']  = 'actions.parent',
    ['g.']    = 'actions.toggle_hidden',
    ['<C-c>'] = 'actions.close',
    ['<C-q>'] = '<cmd>bd!<cr>',
    ['gd']    = {
      desc = 'Toggle file detail view',
      callback = function()
        detail = not detail
        require('hold.Oil').set_columns(detail and { 'icon', 'size', 'mtime' } or { 'icon' })
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
          require('hold.Oil').open(vim.fn.getcwd())
        end
      end
    end)
  end,
})

-- Apply the wrap-around mapping only in Oil buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  callback = function()
    Kset('n', '<Down>', function()
      if vim.fn.line('.') == vim.fn.line('$') then
        vim.cmd('normal! gg')
      else
        vim.cmd('normal! j')
      end
    end, { buffer = true })

    Kset('n', '<Up>', function()
      if vim.fn.line('.') == 1 then
        vim.cmd('normal! G')
      else
        vim.cmd('normal! k')
      end
    end, { buffer = true })
  end,
})
