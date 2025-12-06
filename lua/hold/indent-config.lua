return {
  'snacks.nvim',
  opts = {
    indent = {
      -- see augroups to enable only for .lua and .sh files
      enabled = true, -- enable indent guides
      priority = 1,
      char = '│',
      only_scope = true, -- only show indent guides of the scope
      only_current = true, -- only show indent guides in the current window
      hl = 'SnacksIndent', ---@type string|string[] hl groups for indent guides
      -- dont't show indent on markdown and text files
      filter = function(buf)
        return vim.g.snacks_indent ~= false
          and vim.b[buf].snacks_indent ~= false
          and vim.bo[buf].buftype == ''
          and vim.bo[buf].filetype ~= 'markdown'
          and vim.bo[buf].filetype ~= 'text'
      end,
    },
  },
}
