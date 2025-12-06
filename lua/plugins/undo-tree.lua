-- undo-tree.lua
--
-- Created: 10/17/23

return {
  'mbbill/undotree',
  keys = {
    { '<Leader>u', vim.cmd.UndotreeToggle, desc = 'UndoTree' },
  },
	-- stylua: ignore
	config = function()
		-- set parameters for undo tree
		vim.g.undotree_CursorLine               = 1 -- Show cursorline
		vim.g.undotree_HelpLine                 = 1 -- Show help line
		vim.g.undotree_HighlightChangedText     = 1 -- Highlight changed text
		vim.g.undotree_HighlightChangedWithSign = 1 -- Highlight changed text using signs in the gutter
		vim.g.undotree_RelativeTimestamp        = 1 -- relative timestamp
		vim.g.undotree_WindowLayout             = 2 -- window layout
	end,
}
