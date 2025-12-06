local snacks = require('snacks')

-- Register a picker that filters recent files by current working directory
snacks.register_picker('recent_cwd', function()
  local cwd = vim.fn.getcwd()
  local files = snacks.source('recent')
  local filtered = vim.tbl_filter(function(item)
    return vim.startswith(item.path, cwd)
  end, files)
  return snacks.sort_by_mtime(filtered)
end)
