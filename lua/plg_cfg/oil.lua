--    ╭────────────────────────────╮
--    │          oil.lua           │
--    ╰────────────────────────────╯

-- vim.pack version of old lazy.nvim oil config
-- changed from lazy to vim.pack 3-30-26
-- 04/28/26:
--        simplified code
--        removed indicators of changed oil buffer - no longer worked
--        removed float shortcut
--        Gemini optimized for full-screen and quick startup
-- 09/26/26 - Optimizations and corrections to exclude and dirchanged from Codex

vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
})

local detail = false
local file_exclude = require('file_exclude')
local group = vim.api.nvim_create_augroup('OilConfig', { clear = true })

-- Keymap to Start oil
Kset('n', '=', '<cmd>Oil .<cr>', { desc = 'Oil full screen' })

-- set up oil
-- stylua: ignore
require('oil').setup({
  delete_to_trash               = true,
  skip_confirm_for_simple_edits = true,

  -- Rounded border for :w dialogs
  confirmation = {
    border       = 'rounded',
    win_options  = { winblend = 0 },
  },

  win_options = {
    wrap = true,
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
        local next_detail = not detail
        local has_modified_buffer = false

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == 'oil' and vim.bo[buf].modified then
            has_modified_buffer = true
            break
          end
        end

        require('oil').set_columns(next_detail and { 'icon', 'size', 'mtime' } or { 'icon' })
        if not has_modified_buffer then detail = next_detail end
      end,
    },
  },

  view_options = {
    case_insensitive = true,
    is_hidden_file   = function(name)
      return vim.startswith(name, '.') or file_exclude.is_excluded(name)
    end,
  },
})

-- Optimized Directory Sync (No Float Logic)
vim.api.nvim_create_autocmd('DirChanged', {
  group = group,
  callback = function()
    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'oil' then
          vim.api.nvim_win_call(win, function()
            require('oil').open(vim.fn.getcwd())
          end)
        end
      end
    end)
  end,
  desc = 'Make Oil follow Neovim cwd',
})

-- Apply the wrap-around mapping only in Oil buffers
vim.api.nvim_create_autocmd('FileType', {
  group = group,
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
