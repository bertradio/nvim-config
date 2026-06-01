local starter = require('mini.starter')

-- ───── ───── ───── mini.starter setup - code from Gemini ───── ───── ─────

local num_of_recent = 6 -- number of recent files to display

-- stylua: ignore
starter.setup({
autoopen = false,
auto_setup = false,
evaluate_single = true,
query_line_prefix = '',
show_usage = false,

header = "If it ain't broke, don't fix it!",
footer = function()
  return ''
end,

items = {
  starter.sections.recent_files(num_of_recent, false, false),
  -- {
  --   name = 'Explorer',
  --   action = function()
  --     vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>x', true, true, true))
  --   end,
  --   section = '',
  -- },
  {
    name = 'Find Files',
    action = function()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sf', true, true, true))
    end,
    section = '',
  },
  {
    name = 'Grep',
    action = function()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sg', true, true, true))
    end,
    section = '',
  },
  {
    name = 'New file',
    action = 'enew',
    section = '',
  },
  {
    name = 'Recent Files',
    action = function()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>sr', true, true, true))
    end,
    section = '',
  },
  {
    name = 'Yazi',
    action = function()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Leader>y', true, true, true))
    end,
    section = '',
  },
  { name = 'Quit Menu', action = 'bwipeout', section = '' },
},

content_hooks = {
  starter.gen_hook.adding_bullet(),
  starter.gen_hook.aligning('center', 'center'),
},
silent = true,
})

-- open dashboard
local function open_dashboard()
  pcall(function()
    starter.open()
    -- Maintain your clean, mid-century modern aesthetic
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Normal' })
    vim.cmd('redraw')
  end)
end

-- open dashboard shortcut - force reread of saved data
Kset('n', '<space>]', function()
  -- rshada! necessary to make sure recent list is up to date
  vim.cmd('rshada!')
  open_dashboard()
end, { desc = 'Dashboard', silent = true })
