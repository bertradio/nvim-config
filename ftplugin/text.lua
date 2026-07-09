--    ╭──────────────────────────────────╮
--    │    settings for text filetype    │
--    ╰──────────────────────────────────╯

-- stylua: ignore
local options = {
  spell             = true,
  spelllang         = 'en_us',
  number            = false,
  relativenumber    = false,
  list              = false,
  conceallevel      = 0,
  autoindent        = true,
  tabstop           = 2,
  softtabstop       = 2,
  shiftwidth        = 2,
  wrap              = true,
  linebreak         = true,  -- don't break lines in the middle of words
  showmatch         = false, -- don't match parens
  filetype          = 'text'
}

--use vim.opt to execute settings from options array defined above
for k, v in pairs(options) do
  vim.opt[k] = v
end
