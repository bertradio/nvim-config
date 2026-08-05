-- 04/30/26 - standardized on vim.keymap.set for all mappings
-- 05/06/26 - use Kset for all mappings - defined in init.lua
-- 07/29/26 - added mini.bufremove

-------------------------------------------------
-- >>> MOVEMENT
-------------------------------------------------

-- code from ChatGPT incorporating mini.bufdelete

-- Buffer manipulation

Kset({ 'n' }, '<Leader>bb', '<cmd>bd<cr>', { desc = 'delete buffer' })
Kset({ 'n' }, '<Leader>bc', '<cmd>CopyBufferName<cr>', { desc = 'path copy' })
Kset({ 'n' }, '<Leader>ba', '<cmd>silent %bd<cr>', { desc = 'delete all' })
-- Delete all buffers except the current one
Kset('n', '<leader>bo', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      -- Use pcall (protected call) to catch errors if a buffer is modified
      local success, err = pcall(vim.api.nvim_buf_delete, buf, { force = false })
      if not success then
        print('Skipped modified buffer: ' .. vim.api.nvim_buf_get_name(buf))
      end
    end
  end
end, { desc = 'delete all buffers except current' })

-- Move to beginning and end characters of current buffer
Kset('n', 'gg', 'gg0', { desc = 'Move to first char of file' })
Kset('n', 'G', 'G$', { desc = 'Move to last char of file' })

-- Go up/down one line on the screen rather than one file line at a time
Kset('i', '<down>', '<c-o>gj')
Kset('i', '<up>', '<c-o>gk')
Kset('n', '<up>', 'gk', { desc = 'Move cursor up one line' })
Kset('n', '<down>', 'gj', { desc = 'Move cursor down one line' })
Kset('n', 'k', 'gk', { desc = 'Move cursor up one line' })
Kset('n', 'j', 'gj', { desc = 'Move cursor down one line' })

-------------------------------------------------
-- >>> SAVE AND QUIT
-------------------------------------------------

-- Write current buffer - end in normal mode
Kset({ 'n', 'i' }, '<c-s>', '<esc><cmd>w<cr>', { desc = 'Write buffer' })
-- Exit nvim normally
Kset({ 'n', 'i', 'v' }, '<c-q>', '<cmd>q<cr>', { desc = 'Exit nvim' })

------------------------------------------------
-- >>> WORKING WITH TEXT
-------------------------------------------------

-- load last file
Kset('n', '<Leader>l', '<cmd>e#<1<cr>', { desc = 'Load last file' })

-- disable s key to substitute
Kset({ 'n', 'v' }, 's', '<nop>')

-- Select all text in the current buffer
Kset('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Insert blank lines without going into insert mode
-- adds line and deletes anything that might be on it - stays in normal mode
Kset('n', '<Leader>o', 'o<esc>0"_D', { desc = 'Insert blank line bellow' })
Kset('n', '<Leader>O', 'O<esc>0"_D', { desc = 'Insert blank line above' })

-- Toggle spell
Kset('n', '<Leader>S', '<cmd>set spell!<cr>', { desc = 'Spell check toggle' })

-- Save current buffer and source this file
Kset(
  'n',
  '<Leader>R',
  "<cmd>w<cr><cmd>source %  <cr><cmd>echom '** Saved and Re-sourced **' <cr>",
  { desc = 'Re-source' }
)

-- create copy of line(s) and comment out originals
Kset('n', 'ycc', function()
  vim.cmd('normal! ' .. vim.v.count1 .. 'yy')
  vim.cmd('normal ' .. vim.v.count1 .. 'gcc')
  vim.cmd("normal! ']$p")
end, { desc = 'Duplicate and comment lines' })

-- search only in selected area in visual mode
Kset('x', '/', '<Esc>/\\%V')

-- open file in Typora
Kset(
  'n',
  '<leader>t',
  '<cmd>lua Myfn.OpenInTypora()<CR>',
  { noremap = true, silent = true, desc = 'Open in Typora' }
)

-- use tab in normal mode to open and close folds
Kset('n', '<tab>', function()
  local linenr = vim.fn.line('.')
  -- If there's no fold to be opened/closed, do nothing.
  if vim.fn.foldlevel(linenr) == 0 then
    return
  end

  -- Open fold recursively if closed, close if open.
  local cmd = vim.fn.foldclosed(linenr) == -1 and 'zc' or 'zO'
  vim.cmd('normal! ' .. cmd)
end, { silent = true, desc = 'Folds: Toggle' })

-- update all plugins
Kset('n', '<leader>U', function()
  vim.notify('Updating plugins...', vim.log.levels.INFO)
  vim.cmd('packupdate')
end, { desc = 'Update plugins' })

-- toggle boolean
local function toggle_bool()
  local word = vim.fn.expand('<cword>')
  -- stylua: ignore
  local bool_map = {
    ['true']  = 'false',
    ['false'] = 'true',
    ['True']  = 'False',
    ['False'] = 'True',
    ['TRUE']  = 'FALSE',
    ['FALSE'] = 'TRUE',
    ['on']    = 'off',
    ['off']   = 'on',
    ['1']     = '0',
    ['0']     = '1',
    ['yes']   = 'no',
    ['no']    = 'yes'
  }

  if bool_map[word] then
    vim.cmd('normal! ciw' .. bool_map[word])
  else
    print('Not a boolean!')
  end
end

-- Keymap: Pressing <leader>T will toggle the value
Kset('n', '<leader>T', toggle_bool, { desc = 'Toggle boolean under cursor' })

-- Insert today's date

Kset('i', '<F5>', function()
  vim.api.nvim_put({ os.date('%m/%d/%y - ') }, 'c', true, true)
end, { desc = "Insert today's date" })

--  ───────────── code for search indicators [] and kepmaps ─────────────

-- 1. Create autogroup to handle the cursor movement
local search_group = vim.api.nvim_create_augroup('SearchLens', { clear = true })

-- 2. Keep your n/N mappings simple (just move and center)
Kset('n', 'n', 'nzz', { silent = true })
Kset('n', 'N', 'Nzz', { silent = true })

Kset('n', 'fd', ':find ', { desc = 'find' })

------------------------------------------------
-- >>> WORKING WITH TEXT
-------------------------------------------------

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
