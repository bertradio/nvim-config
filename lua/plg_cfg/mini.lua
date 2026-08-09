--    ╭────────────────────────────╮
--    │          mini.lua          │
--    ╰────────────────────────────╯

-- setup for mini modules
-- changed from lazy to vim.pack 3-30-26
-- put everything in one file for convenience
-- 04/28/26 - lazy loaded based on Gemini advice - from aucmds.lua
-- 04/29/26 - add autocmd to delay most require until typing
-- 05/03/26 - configured menu to replace Snacks - code from Gemini - consolidated and tuned shortcuts
-- 05/04/26 - fixed issue with recent not updating by adding rshada! to shortcut
-- 05/08/26 - cleaned up and optimized starter
-- 05/20/26 - added local requires
-- 06/01/26 - replaced starter with Snacks.dashboard
-- 07/15/26 - added mini.clues and mini.files configs
-- 07/26/26 - added mini.ai - code as per ChatGPT
-- 07/31/26 - added indentscope
-- 08/01/26 - split into separate files except for one-liners

--   Gh('nvim-mini/mini.nvim'),
-- })

local align = require('mini.align')
local bracketed = require('mini.bracketed')
local bufremove = require('mini.bufremove')
local minput = require('mini.input')
local misc = require('mini.misc')

local pick = require('mini.pick')
vim.ui.select = pick.ui_select -- use pick instead of system select

--  ──────────────────────────────────────────────────────

align.setup({ mappings = { start = 'ga' } })

bracketed.setup()

bufremove.setup()

minput.setup()

--  ────── misc setup and code ───────

misc.setup()

-- restore cursor position when opening files
misc.setup_restore_cursor({
  center = false,
  ignore_filetype = { 'commit', 'gitcommit', 'gitrebase', 'xxd' },
})

Kset('n', '<Leader>C', '<cmd>lua require("mini.misc").zoom()<CR>', { desc = 'clean screen toggle' })

--  ──────────────────────────────────
