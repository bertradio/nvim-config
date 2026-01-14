-- uses a bash file -- needs to be modified for windows

return {
  'snacks.nvim',
  opts = {
    dashboard = {
      enabled = false,
      width = 45,
      preset = {
        keys = {
          -- {
          --   icon = ' ',
          --   key = 'e',
          --   desc = 'Explorer',
          --   action = '<Leader><space>',
          -- },
          {
            icon = ' ',
            key = 'f',
            desc = 'Find file',
            action = '<Leader>ff',
          },
          {
            icon = ' ',
            key = 'r',
            desc = 'Recent',
            action = '<Leader>fo',
          },
          {
            icon = ' ',
            key = 'o',
            desc = 'Oil',
            action = '-',
          },
          {
            icon = 'y',
            key = 'y',
            desc = 'yazi',
            action = ':lua require("yazi").yazi()',
          },
          {
            icon = '󰒲 ',
            key = 'l',
            desc = 'Lazy',
            action = ':Lazy',
            enabled = package.loaded.lazy ~= nil,
          },
          {
            icon = 'z',
            key = 'z',
            desc = 'Zoxide',
            action = '<Leader>z',
          },
        },
        header = [[]],
      },
      formats = {
        key = function(item)
          return {
            { '[', hl = 'special' },
            { item.key, hl = 'key' },
            { ']', hl = 'special' },
          }
        end,
      },
      sections = {
        { title = "\nIf it ain't broke, don't fix it", align = 'center', padding = 1 },
        { section = 'recent_files', align = 'left', limit = 10, padding = 1 },
        { section = 'keys', align = 'left', padding = 1 },
      },
    },
  },
}
