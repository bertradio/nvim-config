-- keymaps.lua

-------------------------------------------------
-- >>> MOVEMENT
-------------------------------------------------

-- Move to beginning and end characters of current buffer
Myfn.map('n', 'gg', 'gg0', { desc = 'Move to first char of file' })
Myfn.map('n', 'G', 'G$', { desc = 'Move to last char of file' })

-- Buffer manipulation - also in Snacks.keys-config

Myfn.map({ 'n' }, '<Leader>bc', '<cmd>CopyBufferName<cr>', { desc = 'path copy' })
Myfn.map({ 'n' }, '<Leader>bk', '<cmd>bd!<cr>', { desc = 'kill buffer' })
Myfn.map({ 'n' }, ']b', '<cmd>bnext<cr>', { desc = 'next buffer' })
Myfn.map({ 'n' }, '[b', '<cmd>bprev<cr>', { desc = 'prev buffer' })

-- Go up/down one line on the screen rather than one file line at a time
Myfn.map('i', '<down>', '<c-o>gj')
Myfn.map('i', '<up>', '<c-o>gk')
Myfn.map('n', '<up>', 'gk', { desc = 'Move cursor up one line' })
Myfn.map('n', '<down>', 'gj', { desc = 'Move cursor down one line' })
Myfn.map('n', 'k', 'gk', { desc = 'Move cursor up one line' })
Myfn.map('n', 'j', 'gj', { desc = 'Move cursor down one line' })

-------------------------------------------------
-- >>> SAVE AND QUIT
-------------------------------------------------

-- Write current buffer - end in normal mode
Myfn.map({ 'n', 'i' }, '<c-s>', '<esc><cmd>w<cr>', { desc = 'Write buffer' })

-- Exit nvim normally
-- Myfn.map({ 'n', 'i', 'v' }, '<F10>', '<cmd>q<cr>', { desc = 'Exit nvim' })
Myfn.map({ 'n', 'i', 'v' }, '<c-q>', '<cmd>q<cr>', { desc = 'Exit nvim' })

------------------------------------------------
-- >>> WORKING WITH TEXT
-------------------------------------------------

-- Insert current date and time
-- Myfn.map("n", "<Leader>dt", "<cmd>=strftime('%a %b %d %Y - %H.%M ')<cr>", { desc = 'Insert date and time' })

-- disable s key to substitute
Myfn.map({ 'n', 'v' }, 's', '<nop>')

-- Insert blank lines without going into insert mode
-- adds line and deletes anything that might be on it - stays in normal mode
Myfn.map('n', '<Leader>o', 'o<esc>0"_D', { desc = 'Insert blank line bellow' })
Myfn.map('n', '<Leader>O', 'O<esc>0"_D', { desc = 'Insert blank line above' })

-- Add log time at bottom of file - for log file
-- Myfn.map(
--   'n',
--   '<Leader>L',
--   "Go<C-R>=strftime('# %b %d, %Y')\n\n<cr>",
--   { desc = 'Add log date at bottom' }
-- )

-- Toggle spell
Myfn.map('n', '<Leader>S', '<cmd>set spell!<cr>', { desc = 'Spell check toggle' })

Myfn.map({ 'n', 'i' }, '<C-l>', '<cmd>set hlsearch!<cr>', { desc = 'hlsearch toggle' })

-- Select all - from ChatGPT
Myfn.map('n', '<C-a>', function()
  vim.cmd('normal! ggVG')
end, {
  desc = 'Select all',
  silent = true,
})

-- Yank all
Myfn.map('n', '<C-y>', '<cmd>%y+<cr>', { desc = 'Yank all' })

-- Save current buffer and source this file
Myfn.map('n', '<Leader>R', "<cmd>w<cr><cmd>source %  <cr><cmd>echom '** Re-sourced **' <cr>")

-- map ~ to cycle through case changes in visual mode - in vimscript
-- from https://vim.fandom.com/wiki/Switching_case_of_characters#Twiddle_case
vim.cmd([[
			function! TwiddleCase(str)
					if a:str ==# toupper(a:str)
							let result = tolower(a:str)
					elseif a:str ==# tolower(a:str)
							let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
					else
							let result = toupper(a:str)
					endif
					return result
			endfunction
			vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv
	]])

-- create copy of line(s) and comment out originals
Myfn.map('n', 'ycc', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'yy')
  vim.cmd('normal ' .. vim.v.count1 .. 'gcc')
  vim.cmd("normal! ']$p")
end, { desc = 'Duplicate and comment lines' })

-- search only in selected area in visual mode
Myfn.map('x', '/', '<Esc>/\\%V')

-- run lazy
Myfn.map('n', '<Leader>L', '<cmd>Lazy sync<cr>', { desc = 'Lazy sync' })

-- open file in Typora

vim.api.nvim_set_keymap(
  'n',
  '<leader>t',
  '<cmd>lua Myfn.OpenInTypora()<CR>',
  { noremap = true, silent = true, desc = 'Open in Typora' }
)

-- use tab in normal mode to open and close folds
Myfn.map('n', '<tab>', function()
  local linenr = vim.fn.line('.')
  -- If there's no fold to be opened/closed, do nothing.
  if vim.fn.foldlevel(linenr) == 0 then
    return
  end

  -- Open recursively if closed, close if open.
  local cmd = vim.fn.foldclosed(linenr) == -1 and 'zc' or 'zO'
  vim.cmd('normal! ' .. cmd)
end, { silent = true, desc = 'Folds: Toggle' })
