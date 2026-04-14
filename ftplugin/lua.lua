--    ╭────────────────────────────╮
--    │        lua settings        │
--    ╰────────────────────────────╯

local options = {
  relativenumber = false,
  list = false,
  breakindent = true,
  -- tab and other indent settings
  autoindent = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  -- word wrap on
  wrap = true,
  -- don't break lines in the middle of words
  linebreak = true,
  ft = 'lua',
}

-- use vim.opt to execute settings from options array defined above
for k, v in pairs(options) do
  vim.opt[k] = v
end
