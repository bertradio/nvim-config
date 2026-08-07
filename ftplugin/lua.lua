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

-- use vim.opt_local to execute settings from options array defined above
for k, v in pairs(options) do
  vim.opt_local[k] = v
end

vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
