--    ╭────────────────────────────╮
--    │       my_abbrevs.lua       │
--    ╰────────────────────────────╯

-- list of my abbreviations - called by options.lua
-- Created: 04/27/26

--  ────────── insert mode ───────────

-- stylua: ignore 
local set_iabbrevs = {
  { '@@',   'Bert@KleinmanMedia.com' },
  { 'bk',   'Bert Kleinman' },
  { 'ki',   'Kehillat Israel' },
  { 'ph',   '310 405-5210' },
  { 'stig', '-- stylua: ignore' },
}

for _, v in ipairs(set_iabbrevs) do
  -- This joins the command into: iabbrev bk Bert Kleinman
  vim.cmd('iabbrev ' .. v[1] .. ' ' .. v[2])
end

--  ────────── command line ──────────

-- stylua: ignore 
local set_cabbrevs = {
  { 'vpd', 'vim.pack.del({""})' },
}

for _, v in ipairs(set_cabbrevs) do
  vim.cmd('cabbrev ' .. v[1] .. ' ' .. v[2])
end
