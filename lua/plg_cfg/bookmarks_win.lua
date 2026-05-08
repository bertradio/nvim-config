--    ╭────────────────────────────╮
--    │     bookmarks_win.lua      │
--    ╰────────────────────────────╯

-- set dirs and shortcuts for windows - may need to be revised
-- because directories have changed

local cwd_config = {
  d = 'C:/Users/bertk/Home/Downloads/',
  H = 'C:/Users/bertk/Home',
  h = 'C:/Users/bertk/AppData/Local/nvim/lua/hold/',
  m = 'C:/Users/bertk/OneDrive/My Docs/Moving Forward',
  n = 'C:/Users/bertk/AppData/Local/nvim',
  o = 'C:/Users/bertk/OneDrive/My Docs',
  p = 'C:/Users/bertk/AppData/Local/nvim/plugin/',
  s = 'C:/Users/bertk/OneDrive/My Docs/Share',
  t = 'C:/Users/bertk/Home/Temp',
  v = 'C:/Users/bertk/Insync/bert.kleinman@gmail.com/Google Drive/',
  y = 'C:/Users/bertk/AppData/Roaming/yazi',
}

-- loop to map
for k, d in pairs(cwd_config) do
  Myfn.map_cwd(k, d)
end

-- edit nvim config files
Myfn.map(
  'n',
  '<Leader>ea',
  '<cmd>e C:/Users/bertk/AppData/Local/nvim/lua/augroups.lua<cr>',
  { desc = 'augroups.lua' }
)
Myfn.map(
  'n',
  '<Leader>ei',
  '<cmd>e C:/Users/bertk/AppData/Local/nvim/init.lua<cr>',
  { desc = 'init.lua' }
)
Myfn.map(
  'n',
  '<Leader>ek',
  '<cmd>e C:/Users/bertk/AppData/Local/nvim/lua/keymaps.lua<cr>',
  { desc = 'keymaps.lua' }
)
Myfn.map(
  'n',
  '<Leader>em',
  '<cmd>e C:/Users/bertk/AppData/Local/nvim/lua/my_fns.lua<cr>',
  { desc = 'my_fns.lua' }
)
Myfn.map(
  'n',
  '<Leader>es',
  '<cmd>e C:/Users/bertk/AppData/Local/nvim/lua/settings.lua<cr>',
  { desc = 'settings.lua' }
)
