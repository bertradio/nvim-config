-- code-biscuits.lua
--
-- Created: 07/14/25

return {
  'code-biscuits/nvim-biscuits',
  event = 'VeryLazy',

  config = function()
		-- stylua: ignore
		require('nvim-biscuits').setup({
			default_config = {
				trim_by_words = true,
				max_length    = 4, -- max number of words to display
				min_distance  = 3, -- won't display less than these number of lines
			},
			-- disable for languages
			language_config = {
				markdown = { disabled = true },
				text     = { disabled = true },
			},
		})
  end,
  require('nvim-treesitter.configs').setup({
    ensure_installed = 'maintained',
  }),
}
