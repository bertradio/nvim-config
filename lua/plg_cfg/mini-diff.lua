-- mini-diff.lua

-- Created: 09/06/26

local diff = require('mini.diff')

local sources = {
  save = diff.gen_source.save(),
  git = diff.gen_source.git(),
}

local source_name = 'save'

vim.g.minidiff_disable = true

-- Diff with last saved version or git
-- stylua: ignore 
diff.setup({
  source = sources[source_name],
  view = {
    style = 'sign',
    signs = {
      add = 'A',
      change = 'C',
      delete = 'X',
    },
  },
})

-- Keymaps
Kset('n', '<Leader>do', function()
  diff.toggle_overlay()
end, { desc = 'toggle diff overlay' })

-- Toggle
local function set_saved_reference()
  if not vim.bo.modified then
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  local reference = {}

  if path ~= '' then
    local ok, lines = pcall(vim.fn.readfile, path)

    if not ok then
      vim.notify('Could not read saved file', vim.log.levels.ERROR)
      return
    end

    reference = lines
  end

  diff.set_ref_text(0, reference)
end

local function enable_diff()
  vim.g.minidiff_disable = false
  diff.enable()

  if source_name == 'save' then
    set_saved_reference()
  end
end

-- toggle MiniDiff on and off
Kset('n', '<Leader>dt', function()
  if vim.g.minidiff_disable then
    enable_diff()
    vim.notify('mini.diff enabled')
  else
    diff.disable()
    vim.g.minidiff_disable = true
    vim.notify('mini.diff disabled')
  end
end, { desc = 'toggle mini.diff' })

-- Toggle between saved file and git for reference
Kset('n', '<Leader>ds', function()
  local was_enabled = not vim.g.minidiff_disable

  diff.disable()

  source_name = source_name == 'save' and 'git' or 'save'
  diff.config.source = sources[source_name]

  if was_enabled then
    enable_diff()
  end

  vim.notify('mini.diff chaged source to: ' .. source_name)
end, { desc = 'toggle mini.diff source' })
