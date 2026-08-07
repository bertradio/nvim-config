--    ╭────────────────────────────╮
--    │     markdown settings      │
--    ╰────────────────────────────╯

--  ──────────── mappings ────────────

-- make mappings local to the markdown buffer with buffer = true
Myfn.map('v', '<Leader>b', '<esc>`>a**<esc>`<i**<esc>', { buffer = true, desc = 'Make bold' })
Myfn.map('v', '<Leader>i', '<esc>`>a*<esc>`<i*<esc>', { buffer = true, desc = 'Make italic' })

--  ───── Other Markdown File Settings ─────

-- stylua: ignore
local options = {
	autoindent     = true,
	autoread       = true, -- automatically re-read the file if changed outside nvim
	breakindent    = true,
	conceallevel   = 0,
	filetype       = 'markdown',
	linebreak      = true, -- don't break lines in the middle of words
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

--use vim.opt_local to execute settings from options array defined above
for k, v in pairs(options) do
  vim.opt_local[k] = v
end
