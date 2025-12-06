-- settings for text filetype

-- stylua: ignore
local options = {
  number            = false,
  relativenumber    = false,
  list              = false,
  conceallevel      = 0,
  autoindent        = true,
  tabstop           = 4,
  softtabstop       = 4,
  shiftwidth        = 4,
  wrap              = true,
  linebreak         = true,  -- don't break lines in the middle of words
  showmatch         = false, -- don't match parens
}

--use vim.opt to execute settings from options array defined above

for k, v in pairs(options) do
  vim.opt[k] = v
end
