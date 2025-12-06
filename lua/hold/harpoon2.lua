-- lua/plugins/harpoon.lua
-- ChatGPT to keep one global list
--
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },

  config = function()
    local ok, harpoon = pcall(require, 'harpoon')
    if not ok then
      vim.notify('harpoon not found', vim.log.levels.WARN)
      return
    end

    -- REQUIRED for Harpoon2
    harpoon:setup({})

    -- Always use a global list (not cwd/project specific)
    local function glist()
      return harpoon:list('global')
    end

    -- Quick menu
    vim.keymap.set('n', '<leader>hh', function()
      require('harpoon.ui').toggle_quick_menu(glist())
    end, { desc = 'Harpoon: Toggle quick menu (global)' })

    -- Add current file
    vim.keymap.set('n', '<leader>ha', function()
      glist():add()
    end, { desc = 'Harpoon: Add file (global)' })

    -- Numbered jumps
    vim.keymap.set('n', '<leader>h1', function()
      glist():select(1)
    end, { desc = 'Harpoon: File 1 (global)' })
    vim.keymap.set('n', '<leader>h2', function()
      glist():select(2)
    end, { desc = 'Harpoon: File 2 (global)' })
    vim.keymap.set('n', '<leader>h3', function()
      glist():select(3)
    end, { desc = 'Harpoon: File 3 (global)' })
    vim.keymap.set('n', '<leader>h4', function()
      glist():select(4)
    end, { desc = 'Harpoon: File 4 (global)' })

    -- Cycle prev/next
    vim.keymap.set('n', '<leader>hp', function()
      glist():prev()
    end, { desc = 'Harpoon: Previous (global)' })
    vim.keymap.set('n', '<leader>hn', function()
      glist():next()
    end, { desc = 'Harpoon: Next (global)' })
  end,
}
