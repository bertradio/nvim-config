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
  -- page break in pdf for printing
  { 'pgbk', '<div style ="page-break-after:always"></div>' },
  { 'stig', '-- stylua: ignore' },
  { 'h1', '#'},
  { 'h2', '##'},
  { 'h3', '###'},
  { 'h4', '####'},
}

for _, v in ipairs(set_iabbrevs) do
  -- This joins the command into: iabbrev bk Bert Kleinman
  vim.cmd('iabbrev ' .. v[1] .. ' ' .. v[2])
end
