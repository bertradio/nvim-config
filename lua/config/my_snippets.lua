-- my_snippets.lua
--
-- Created: 04/24/26

--  ───── add triggers and snippets ─────

-- stylua: ignore 
local snips = {
  { 'bk',   'Bert Kleinman' },
  { 'copy', 'Copyright (c) 2026 Bert Kleinman. All rights reserved.' },
  { 'eml',  'Bert@KleinmanMedia.com' },
  { 'ss',   'Shabbat Shalom' },
  { 'stig', ' -- stylua: ignore'},
}

--  ────────── end snippets ──────────

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node

-- to make snippets easier to code
local function mksnip(snip, text)
  return s(snip, { t(text) })
end

-- loop through snips
local built = {}
for _, x in ipairs(snips) do
  built[#built + 1] = mksnip(x[1], x[2])
end
ls.add_snippets('all', built)
