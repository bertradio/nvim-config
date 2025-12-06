-- nvim-tree

-- Map to toggle NvimTree
Myfn.map('n', '<Leader>[', '<cmd>NvimTreeToggle<cr>', { desc = 'NvimTreeToggle' })

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true -- set termguicolors to enable highlight groups

-- remap keys for my preferences - from nvim-tree docs
local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  -- default mappings
  api
    .config
    .mappings
    .default_on_attach(bufnr)
    -- my custom mappings
    .map('n', '<c-g>', api.tree.change_root_to_parent, opts('Up'))
    .map('n', '<c-t>', api.tree.change_root_to_node, opts('CD here'))
    .map('n', '?', api.tree.toggle_help, opts('Help'))
end

-- call and setup

return {

  'nvim-tree/nvim-tree.lua',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
    sort_by = 'case_sensitive',
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
    -- attach my custom mappings with function defined above
    on_attach = my_on_attach,
  },
  config = function()
    require('nvim-tree').setup({
      sync_root_with_cwd = true,
    })
  end,
}
