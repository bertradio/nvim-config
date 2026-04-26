--    ╭────────────────────────────╮
--    │      my_snippets.lua       │
--    ╰────────────────────────────╯

-- Created: 04/24/26

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- uncomment to use
-- local d = ls.dynamic_node
local fmt = require('luasnip.extras.fmt').fmt

--  ───── snippets for all files ─────

ls.add_snippets('all', {
  s('td', {
    f(function()
      return os.date('%m/%d/%y ')
    end),
  }),
  s('copy', t('Copyright (c) 2026 Bert Kleinman. All Rights Reserved.')),
})

--  ────────── Lua snippets ──────────

ls.add_snippets('lua', {
  s(
    'cmd',
    fmt('<cmd>{}<cr>', {
      i(1, 'command'),
    })
  ),
  s(
    'gh',
    fmt('vim.pack.add( Gh("{}") ) ', {
      i(1, 'Link'),
    })
  ),
  s(
    'rset',
    fmt("require('{}').setup()", {
      i(1, 'module'),
    })
  ),
  s('stig', t('-- stylua: ignore')),
  s(
    'pack',
    fmt(
      [[
        -- {}
        vim.pack.add({{ Gh( "{}" ) }})
        require("{}").setup({{
            {}
        }})
      ]],
      {
        i(1, 'Plugin Description'),
        i(2, 'link'),
        i(3, 'plugin_name'),
        i(0),
      }
    )
  ),
  s(
    'map',
    fmt([[Snacks.keymap.set("{}", "<Leader>{}", "{}", {{ desc = "{}" }})]], {
      i(1, 'n'),
      i(2, 'key'),
      i(3, 'command'),
      i(4, 'desc'),
    })
  ),
})

--  ───── For Markdown, Text, and New/Unnamed Buffers ─────

-- stylua: ignore
local writing_snips = {
  s('bk',   t('Bert Kleinman')),
  s('eml',  t('Bert@KleinmanMedia.com')),
  s('ph',   t('310 450-5210')),
}

-- Loop through the types and add the snippets to each
for _, ft in ipairs({ 'markdown', 'text', '' }) do
  ls.add_snippets(ft, writing_snips)
end

--  ──────── end for writing ─────────
