--    ╭────────────────────────────╮
--    │        xml settings        │
--    ╰────────────────────────────╯

local options = {
  number = true,
  list = false,
  conceallevel = 0,
  breakindent = true,
  breakindentopt = 'shift:2',
  -- tab and other indent settings
  autoindent = true,
  tabstop = 4,
  softtabstop = 4,
  shiftwidth = 4,
  -- word wrap on
  wrap = true,
  -- don't break lines in the middle of words
  linebreak = true,
}

-- use vim.opt_local to execute settings from options array defined above
for k, v in pairs(options) do
  vim.opt_local[k] = v
end
