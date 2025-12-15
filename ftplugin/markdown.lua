---------- >> Mappings << ---------------

-- make mappings local to the markdown buffer with buffer = true
Myfn.map('v', '<Leader>b', '<esc>`>a**<esc>`<i**<esc>', { buffer = true, desc = 'Make bold' })
Myfn.map('v', '<Leader>i', '<esc>`>a*<esc>`<i*<esc>', { buffer = true, desc = 'Make italic' })

---------- >> Other Markdown File Settings << ---------------
-- stylua: ignore
local options = {
	-- breakindentopt = 'shift:2',
	-- tab and other indent settings
	-- foldexpr       = 'nvim_treesitter#foldexpr()',
	-- foldlevelstart = 1,
	-- foldmethod     = 'expr',	 -- set up default folding
	autoindent     = true,
	autoread       = true, -- automatically re-read the file if changed outside nvim
	breakindent    = true,
	conceallevel   = 0,
	filetype       = 'markdown',
	linebreak      = true, -- don't break lines in the middle of words
	-- foldcolumn     = 'auto',    -- set location of fold markers
	-- foldlevel	     = 99,
	list           = false,
	number         = false,
	relativenumber = false,
	shiftwidth     = 2,
	showmatch      = false, -- don't match parens, etc.
	softtabstop    = 2,
	spell          = true, -- spell on
	tabstop        = 2,
	wrap           = true,
}

--use vim.opt to execute settings from options array defined above

for k, v in pairs(options) do
	vim.opt[k] = v
end
