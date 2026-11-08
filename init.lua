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

-- set up colorscheme before everything
misc.safely('now', function()
  -- A colorscheme failure should not stop configuration loading.
  vim.pack.add({ Gh('folke/tokyonight.nvim') })
  require('tokyonight').setup({})
  vim.cmd.colorscheme('tokyonight-night')

  vim.pack.add({ Gh('folke/snacks.nvim') })
  require('snacks') -- Initialize the Snacks global before startup plugin scripts run.
end)

Kset = vim.keymap.set

vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input.input

-- wrapper for misc.safely to make code clearer
function Safereq(plugin)
  misc.safely('now', function()
    require(plugin)
  end)
end

Safereq('settings')
Safereq('plugin_setup')

-------------------------------------------------------------------------

-- for all keymaps
-- to check for dupes comment this out and uncomment the code below

-- Kset = vim.keymap.set

-- local seen = {}
-- function Kset(mode, lhs, rhs, opts)
--   local modes = type(mode) == 'table' and mode or { mode }
--
--   -- Capture the caller now, while its stack information exists.
--   local caller = debug.getinfo(2, 'Sl')
--   local current = {
--     file = caller and caller.short_src or 'unknown',
--     line = caller and caller.currentline or 0,
--   }
--
--   for _, m in ipairs(modes) do
--     local key = m .. '\0' .. lhs
--     local previous = seen[key]
--
--     if previous then
--       vim.schedule(function()
--         vim.notify(
--           string.format(
--             'Duplicate keymap:\n\n%s  %s\n\nPrevious: %s:%d\nCurrent:  %s:%d',
--             m,
--             lhs,
--             previous.file,
--             previous.line,
--             current.file,
--             current.line
--           ),
--           vim.log.levels.WARN
--         )
--       end)
--     end
--
--     seen[key] = current
--   end
--
--   vim.keymap.set(mode, lhs, rhs, opts)
-- end
