--    ╭────────────────────────────╮
--    │      my_snippets.lua       │
--    ╰────────────────────────────╯

local M = {}

local snippets = {
  -- Available in every filetype
  all = {
    td = function()
      return os.date('%m/%d/%y')
    end,

    tm = function()
      return os.date('%m/%d/%y - %H:%m')
    end,

    crt = function()
      return ('Copyright (c) %s Bert Kleinman. All Rights Reserved.'):format(os.date('%Y'))
    end,
  },

  -- Available only in Lua files
  lua = {
    cmd = [['<cmd>${1:command}<cr>'$0]],

    gh = [[vim.pack.add({ Gh('${1:Repo}') })$0]],

    map = [[Kset('${1:n}', '<Leader>${2:key}', '${3:command}', { desc = '${4:desc}' })$0]],

    rset = [[require('${1:module}').setup()$0]],
  },
}

--  ──────── helper functions ────────

local function get_snippet(trigger)
  local filetype = vim.bo.filetype
  local filetype_snippets = snippets[filetype]

  if filetype_snippets and filetype_snippets[trigger] then
    return filetype_snippets[trigger]
  end

  return snippets.all[trigger]
end

function M.expand()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]

  local line = vim.api.nvim_get_current_line()
  local before_cursor = line:sub(1, col)

  -- Get the word immediately before the cursor
  local trigger = before_cursor:match('([%w_]+)$')

  if not trigger then
    return false
  end

  local snippet = get_snippet(trigger)

  if not snippet then
    return false
  end

  -- Dynamic snippets are stored as functions
  local body = type(snippet) == 'function' and snippet() or snippet

  -- Remove the trigger before expanding the snippet
  local start_col = col - #trigger

  vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {})

  vim.snippet.expand(body)

  return true
end

function M.setup()
  Kset('i', '<C-j>', function()
    if M.expand() then
      return
    end

    -- Keep normal <C-j> behavior when no snippet matches
    vim.api.nvim_feedkeys(vim.keycode('<C-j>'), 'n', false)
  end, {
    desc = 'Expand snippet',
  })
end

return M
