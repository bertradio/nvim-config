--    ╭────────────────────────────╮
--    │    bookmarks_linux.lua     │
--    ╰────────────────────────────╯

-- Directory bookmarks with vim.ui.select (dressing.nvim)
-- Uses your Myfn.short_cwd() to shorten displayed paths.
-- Keys:
--   \x  -> jump directly
--   \\  -> open floating picker
-- Code from ChatGPT to add picker using Dressing?

----------------------------------------------------------
-- Bookmark configuration
----------------------------------------------------------
local cwd_config = {
  b = '$HOME/bin',
  c = '$HOME/.config',
  d = '$HOME/.Download',
  h = '$HOME/.config/nvim/hold/',
  H = '$HOME/',
  l = '$HOME/.local/bin',
  L = '$HOME/.config/nvim/lua',
  m = '$HOME/Insync/bertkleinman@outlook.com/OneDrive/My Docs/Moving Forward/',
  n = '$HOME/.config/nvim',
  o = '$HOME/Insync/bertkleinman@outlook.com/OneDrive/My Docs/',
  p = '$HOME/.config/nvim/lua/plg_cfg/',
  s = '$HOME/Insync/bertkleinman@outlook.com/OneDrive/My Docs/Share/',
  S = '$HOME/.Download/Shavuot/',
  t = '$HOME/.Temp/',
  v = '$HOME/Insync/bert.kleinman@gmail.com/Google Drive',
  w = '$HOME/Insync/bertkleinman@outlook.com/OneDrive/My Docs/Moving Forward/Wisteria',
  y = '$HOME/.config/yazi',
}

----------------------------------------------------------
-- Utilities
----------------------------------------------------------

local function expand_home(path)
  local home = vim.env.HOME or '~'
  path = path:gsub('^~', home)
  path = path:gsub('%$HOME', home)
  return vim.fn.expand(path)
end

local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

----------------------------------------------------------
-- Per-key mappings: '\' + key
----------------------------------------------------------
local function map_cwd(key, dir, cd_cmd)
  local lhs = '\\' .. key
  local cmd = cd_cmd or 'cd'
  Kset('n', lhs, function()
    local target = expand_home(dir)
    if not is_dir(target) then
      vim.notify('Not a directory: ' .. target, vim.log.levels.ERROR)
      return
    end
    vim.cmd(string.format('%s %s', cmd, vim.fn.fnameescape(target)))
    vim.notify('cwd → ' .. target)
  end, { desc = ('cd → %s'):format(dir) })
end

for k, d in pairs(cwd_config) do
  map_cwd(k, d, 'cd')
end

----------------------------------------------------------
-- Picker using vim.ui.select (Dressing styles it)
----------------------------------------------------------
local function open_cwd_picker(cd_cmd)
  local keys = {}
  for k, _ in pairs(cwd_config) do
    table.insert(keys, k)
  end
  table.sort(keys)

  local entries = {}
  for _, k in ipairs(keys) do
    local path = cwd_config[k]
    local resolved = expand_home(path)

    -- use shortener
    local short = Myfn.short_cwd({ cwd = resolved, keep_first = 1, keep_last = 2 })

    table.insert(entries, {
      key = k,
      path = path,
      label = string.format('[%s] %s', k, short),
    })
  end

  if #entries == 0 then
    vim.notify('No bookmarks defined', vim.log.levels.WARN)
    return
  end

  vim.ui.select(entries, {
    prompt = 'Jump to directory',
    kind = 'cwd_picker', -- lets Dressing control size
    -- rows = #entries,
    rows = 20,
    format_item = function(it)
      return it.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    local target = expand_home(choice.path)
    if not is_dir(target) then
      vim.notify('Not a directory: ' .. target, vim.log.levels.ERROR)
      return
    end
    local cmd = cd_cmd or 'cd'
    vim.cmd(string.format('%s %s', cmd, vim.fn.fnameescape(target)))
    vim.notify(('cwd → %s'):format(target))
  end)
end

Kset('n', '\\\\', function()
  open_cwd_picker('cd')
end, { desc = 'Pick bookmarked directory' })

-- edit nvim config files
local cfg = vim.fn.stdpath('config')
Myfn.map('n', '<Leader>ea', '<cmd>e ' .. cfg .. '/lua/aucmds.lua<cr>', { desc = 'aucmds.lua' })
Myfn.map('n', '<Leader>ei', '<cmd>e ' .. cfg .. '/init.lua<cr>', { desc = 'init.lua' })
Myfn.map('n', '<Leader>ek', '<cmd>e ' .. cfg .. '/lua/keymaps.lua<cr>', { desc = 'keymaps.lua' })
Myfn.map('n', '<Leader>em', '<cmd>e ' .. cfg .. '/lua/my_fns.lua<cr>', { desc = 'my_fns.lua' })
Myfn.map('n', '<Leader>eo', '<cmd>e ' .. cfg .. '/lua/options.lua<cr>', { desc = 'options.lua' })
Myfn.map(
  'n',
  '<Leader>ep',
  '<cmd>e ' .. cfg .. '/lua/plugin_setup.lua<cr>',
  { desc = 'plugins.lua' }
)
Myfn.map('n', '<Leader>es', '<cmd>e ' .. cfg .. '/lua/settings.lua<cr>', { desc = 'settings.lua' })
