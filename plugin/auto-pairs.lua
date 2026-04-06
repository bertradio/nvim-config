-- nvim-autopairs.lua
-- changed from lazy to -- -- vim.pack 3-30-26
-- better than mini.pairs since it handles quotes before and after text well
-- Created: 03/30/25

-- vim.pack.add({ 'https://github.com/windwp/nvim-autopairs' })

local npairs = require('nvim-autopairs')
npairs.setup({})

local Rule = require('nvim-autopairs.rule')
npairs.add_rules({
  Rule('<', '>'),
  Rule('*', '*', 'markdown'),
})
