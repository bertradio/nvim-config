--    ╭────────────────────────────╮
--    │          init.lua          │
--    ╰────────────────────────────╯

-- changed from lazy to vim.pack 3-30-26
-- moved all settings to settings.lua 4/10/26 - only requires here
-- also move all adds to individual file and lazy loaded with plugin_setup
-- 05/03/26 - added code to configure MiniStarter
-- 07/12/26 - removed code for mini.starter since not used
-- 08/03/26 - fix for Chromebook paste - otherwise crashes with nigihtly
-- 08/04/26 - added code to check for dupllicate keymaps

-- disable nvim splash screen
vim.opt.shortmess:append('I')

-- fixes problem in crostini with paste
vim.opt.clipboard = '' -- Disable auto clipboard
vim.g.clipboard = {
  name = 'xclip',
  copy = {
    ['+'] = 'xclip -selection clipboard',
  },
  paste = {
    ['+'] = 'xclip -selection clipboard -o',
  },
  cache_enabled = 1,
}

Gh = function(x)
  return 'https://github.com/' .. x
end

-- needed so safe loads work
-- Load the error-handling helper first.
vim.pack.add({ Gh('nvim-mini/mini.nvim') })
vim.pack.add({ Gh('nvim-tree/nvim-web-devicons') })
local misc = require('mini.misc')

-- A colorscheme failure should not stop configuration loading.
-- so wrap in misc.safely
misc.safely('now', function()
  vim.pack.add({ Gh('folke/tokyonight.nvim') })
  require('tokyonight').setup({
    on_colors = function(colors)
      colors.comment = '#8993b5'
    end,
  })
  vim.cmd.colorscheme('tokyonight-night')
end)

-- Snacks is required by later configuration.
-- so don't wrap in misc.safely
vim.pack.add({ Gh('folke/snacks.nvim') })
require('snacks')

vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input.input

Kset = vim.keymap.set

-- wrapper for misc.safely to make code clearer
function Safereq(plugin)
  misc.safely('now', function()
    require(plugin)
  end)
end

Safereq('settings')
Safereq('plugin_setup')
