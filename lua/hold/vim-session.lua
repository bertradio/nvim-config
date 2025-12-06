-- vim-session.lua
-- to save and manage multiple sessions
--
-- Created: 11/24/23

-- stylua: ignore
local function M()
	vim.g.session_autoload    = 'no'                          -- don't autoload last session on opening nvim
	vim.g.session_autosave    = 'yes'                         -- auto save session as close of nvim (no prompt)
	vim.g.session_autosave_to = 'Last'                        -- name of autosave session
	vim.g.session_directory   = '~/.local/share/nvim/session' -- location of session files

.map('n', '<Leader>Sc', '<cmd>CloseSession<cr>', { desc = 'Close session' })
.map('n', '<Leader>Sd', '<cmd>DeleteSession<cr>', { desc = 'Delete session' })
.map('n', '<Leader>Sn', ':SaveSession', { desc = 'New session' })
.map('n', '<Leader>So', '<cmd>OpenSession<cr>', { desc = 'Open session' })
.map('n', '<Leader>Ss', '<cmd>SaveSession<cr>', { desc = 'Save session' })
.map('n', '<Leader>Sv', '<cmd>ViewSession<cr>', { desc = 'View current session' })
end
M()

return {
	'xolox/vim-session',
	dependencies = 'xolox/vim-misc',
}
