-- neoclip.lua
--
-- to save deleted clips and access with telescope
--
-- Created: 12/06/23

-- local functions for filtering out of lines that are all whitespace
local function is_whitespace(line)
  return vim.fn.match(line, [[^\s*$]]) ~= -1
end
local function all(tbl, check)
  for _, entry in ipairs(tbl) do
    if not check(entry) then
      return false
    end
  end
  return true
end

return {
  'AckslD/nvim-neoclip.lua',
  -- need to lazy load, otherwise telescope sometimes deletes all history
  lazy = true,
  dependencies = {
    { 'kkharji/sqlite.lua', module = 'sqlite' },
    -- since neoclip is a dependency of telescope (elsewhere) and
    -- nvim-neoclip is lazy loaded, telescope not needed here
    -- even though it's in the docs
    -- 'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('neoclip').setup({
      -- the following lines set up so clips are stored from session to session
      -- To clear all entries from the sqlite3 database run
      -- :lua require('neoclip').clear_history()`
      enable_persistent_history = true,
      history = 200, -- number of clips to save - reduced from 1000
      length_limit = 1048576,
      continuous_sync = false,
      db_path = vim.fn.stdpath('data') .. '/databases/neoclip.sqlite3',
      -- don't store entries that are all whitespace - see fns above
      filter = function(data)
        return not all(data.event.regcontents, is_whitespace)
      end,
			--stylua: ignore
			keys = {
				telescope = {
					i = {
						delete       = "<c-d>", -- delete an entry
						edit         = "<c-e>", -- edit an entry
						paste        = "<c-p>",
						paste_behind = "<c-k>",
						replay       = "<c-q>", -- replay a macro
						select       = "<cr>",
						custom       = {},
					},
					n = {
						--- It is possible to map to more than one key.
						-- paste = { 'p', '<c-p>' },
						delete       = "d",
						edit         = "e",
						paste        = "p",
						paste_behind = "P",
						replay       = "q",
						select       = "<cr>",
						custom       = {},
					},
				},
			},
    })
  end,
}
