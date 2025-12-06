-- fyler.lua
--
-- Created: 11/10/25

return {

	"A7Lavinraj/fyler.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	branch = "stable",
	opts = {
		hooks = {},
		integrations = {
			icon = "mini_icons",
		},
		views = {
			finder = {
				close_on_select = true,
				confirm_simple = false,
				default_explorer = false,
				delete_to_trash = true,
				icon = {
					directory_collapsed = nil,
					directory_empty = nil,
					directory_expanded = nil,
				},
				mappings = {
					["q"] = "CloseView",
					["<CR>"] = "Select",
					["<C-t>"] = "SelectTab",
					["|"] = "SelectVSplit",
					["-"] = "SelectSplit",
					["^"] = "GotoParent",
					["="] = "GotoCwd",
					["."] = "GotoNode",
					["#"] = "CollapseAll",
					["<BS>"] = "CollapseNode",
				},
				follow_current_file = true,
				watcher = {
					enabled = true,
				},
			},
		},
	}

}
