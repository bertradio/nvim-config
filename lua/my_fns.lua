--    ╭────────────────────────────╮
--    │         my_fns.lua         │
--    ╰────────────────────────────╯

-- my global functions available to all lua files
-- all are called with Myfn.
-- required in init.lua

-- Created: 10/16/23

local M = {}

-- detect if running on Windows or Linux
function M.is_windows()
  return require('platform').is_windows()
end

-- Add a directory to PATH (cross-platform, idempotent)
function M.add_to_vim_path(dir, opts)
  return require('platform').add_to_vim_path(dir, opts)
end

-- Wrapper for mapping custom keybindings to make mapping code easier and cleaner - from internet
-- changed from vim.keymap to Snacks.keymap 4-20-26
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true } -- sets defaults
  options = opts and vim.tbl_extend('force', options, opts)
  Snacks.keymap.set(mode, lhs, rhs, options) -- maps key
end

-- simplify setting up maps to change cwd
-- k is the key to use
-- dir is the dir to change to
-- suggestion for simplicity from Perplexity
function M.map_cwd(k, dir)
  Snacks.keymap.set(
    'n',
    '\\' .. k,
    '<cmd>cd! ' .. dir .. '<cr><cmd>lua vim.notify(vim.fn.getcwd(), "info", { title = "" })<cr>',
    { noremap = true, silent = true, desc = 'Set cwd to ' .. dir }
  )
end

-- to shorten cwd for display
-- simpler code from Perplexity
function M.short_cwd(opts)
  opts = vim.tbl_deep_extend('force', {
    keep_first = 2,
    keep_last = 2,
    sep = '/', -- will be overwritten per OS
    cwd = nil, -- add this
  }, opts or {})

  local sep = Myfn.is_windows() and '\\' or '/'
  opts.sep = sep

  -- If a path is given, use that instead of current cwd
  local cwd = opts.cwd or (vim.uv and vim.uv.cwd() or vim.fn.getcwd())

  -- Replace home dir with ~
  local home = vim.env.HOME or vim.fn.expand('~')
  cwd = cwd:gsub('^' .. vim.pesc(home), '~')

  -- Split and shorten
  local parts = vim.split(cwd, vim.pesc(sep))
  local total = #parts

  if total > opts.keep_first + opts.keep_last then
    local new_parts = {}
    for i = 1, opts.keep_first do
      table.insert(new_parts, parts[i])
    end
    table.insert(new_parts, '…')
    for i = total - opts.keep_last + 1, total do
      table.insert(new_parts, parts[i])
    end
    parts = new_parts
  end

  return table.concat(parts, sep)
end

--  to return a centered string
function M.center_string(text, width)
  local padding = math.floor((width - #text) / 2)
  return string.rep(' ', padding) .. text .. string.rep(' ', width - #text - padding)
end

-- Cross-platform "file exists" check
-- quick file exists
-- simple "file exists"
local function file_exists(p)
  if not p or p == '' then
    return false
  end
  return vim.loop.fs_stat(p) ~= nil
end

-- open file in Typora cross platform from ChatGPT
-- find Typora on Windows
local function find_typora_win()
  local cands = {
    'C:\\Program Files\\Typora\\Typora.exe',
    (os.getenv('LOCALAPPDATA') or '') .. '\\Programs\\Typora\\Typora.exe',
  }
  for _, p in ipairs(cands) do
    if file_exists(p) then
      return p
    end
  end
  -- try PATH
  local where_out = vim.fn.systemlist({ 'where', 'Typora' })
  for _, line in ipairs(where_out or {}) do
    if line and line:match('Typora%.exe$') and file_exists(line) then
      return line
    end
  end
  return 'Typora.exe' -- fallback (if it's on PATH)
end

-- escape single quotes for PowerShell single-quoted literals
local function psq(s)
  return (tostring(s):gsub("'", "''"))
end

-- prefer pwsh when available
local function pwsh_or_windows_ps()
  return vim.fn.executable('pwsh') == 1 and 'pwsh' or 'powershell'
end

function M.OpenInTypora()
  local file_path = vim.fn.expand('%:p')
  if not (file_path and file_path ~= '') then
    vim.notify('File name blank or not saved.', vim.log.levels.WARN)
    return
  end

  -- save first
  if vim.bo.modified then
    local ok, err = pcall(vim.cmd.write)
    if not ok then
      vim.notify('Could not save before opening Typora: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  local is_win = (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1)
  if not is_win then
    -- non-Windows (macOS/Linux)
    local cmd = vim.fn.has('mac') == 1 and { 'open', '-a', 'Typora', file_path }
      or { 'typora', file_path }
    local jid = vim.fn.jobstart(cmd, { detach = true })
    if jid <= 0 then
      vim.notify('Failed to spawn Typora.', vim.log.levels.ERROR)
      return
    end
    print('Opening in Typora: ' .. file_path)
    return
  end

  -- Windows: always call Typora.exe directly
  local typora = find_typora_win()

  -- 1) try direct process spawn (no shell, most reliable)
  local jid = vim.fn.jobstart({ typora, file_path }, {
    detach = true,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify(
            'Typora exited immediately with code '
              .. tostring(code)
              .. ' (trying PowerShell fallback)...',
            vim.log.levels.WARN
          )
        end)
      end
    end,
  })

  if jid > 0 then
    print('Opening in Typora: ' .. file_path)
    return
  end

  -- 2) fallback: PowerShell Start-Process (handles some GUI spawn quirks)
  local ps_cmd = string.format(
    "$ErrorActionPreference='Stop'; Start-Process -FilePath '%s' -ArgumentList @('%s') -WindowStyle Normal",
    psq(typora),
    psq(file_path)
  )

  local err_lines = {}
  local shell = pwsh_or_windows_ps()
  local jid2 = vim.fn.jobstart({ shell, '-NoProfile', '-NonInteractive', '-Command', ps_cmd }, {
    detach = true,
    stderr_buffered = true,
    on_stderr = function(_, data, _)
      if data then
        for _, l in ipairs(data) do
          if l and l ~= '' then
            table.insert(err_lines, l)
          end
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        local msg = 'Failed to launch Typora via PowerShell (exit ' .. tostring(code) .. ').'
        if #err_lines > 0 then
          msg = msg .. '\n' .. table.concat(err_lines, '\n')
        end
        vim.schedule(function()
          vim.notify(msg, vim.log.levels.ERROR)
        end)
      end
    end,
  })

  if jid2 <= 0 then
    vim.notify('Could not spawn Typora (direct + PowerShell both failed).', vim.log.levels.ERROR)
    return
  end

  print('Opening in Typora: ' .. file_path)
end

-- to set up simple centered selection menu
-- see telescope.lua for example

-- function M.menu(prompt, options_table)
-- 	--@field prompt
-- 	--@field options_table
-- 	-- Given the table of options, populate a list with option display names
-- 	-- needs dressing.lua for proper display - dependency of telescope
-- 	local option_names = {}
-- 	local n = 0
-- 	for i, _ in pairs(options_table) do
-- 		n = n + 1
-- 		option_names[n] = i
-- 	end
-- 	table.sort(option_names)
-- 	-- Return the prompt function. These global function var will be used when assigning keybindings
-- 	local menu = function()
-- 		vim.ui.select(
-- 			option_names,      --> the list we populated above
-- 			{
-- 				prompt = prompt, --> Prompt passed as the argument
-- 				-- Remove this variable if you want to keep the numbering in front of option names
-- 				format_item = function(item)
-- 					return item:gsub('%d. ', '')
-- 				end,
-- 			},
-- 			function(choice)
-- 				local action = options_table[choice]
-- 				-- When user inputs ESC or q, don't take any actions
-- 				if action ~= nil then
-- 					if type(action) == 'string' then
-- 						vim.cmd(action)
-- 					elseif type(action) == 'function' then
-- 						action()
-- 					end
-- 				end
-- 			end
-- 		)
-- 	end
-- 	return menu
-- end

-- create command CopyBufferName  to copy buffer path to clipboard
-- bound to <Leader>cb in keymaps.lua
local function copy_buffer_name()
  local path = vim.fn.expand('%:p')
  local quoted = '"' .. path .. '"'
  vim.fn.setreg('+', quoted)
  vim.notify('Copied to clipboard: ' .. quoted, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('CopyBufferName', copy_buffer_name, {})

-- function to simplify using vim.add.pack
-- Ensure repos is a table even if a single string is passed
function M.add_pack(spec)
  -- 1. Normalize input into a list of specs
  -- If spec is a string, wrap it. If it's a table but has no numeric indices,
  -- it's a single "advanced" spec, so wrap that too.
  local specs = {}
  if type(spec) == 'string' then
    specs = { { spec } }
  elseif type(spec) == 'table' then
    if spec[1] or spec.src then
      -- It's a single spec table: { "user/repo", version = "v1" }
      specs = { spec }
    else
      -- It's already a list of specs: { "repo1", { "repo2", version = "v2" } }
      specs = spec
    end
  end

  for _, item in ipairs(specs) do
    -- Ensure item is a table
    local plugin = type(item) == 'string' and { item } or item

    -- Extract and format the URL/Source
    local src = plugin[1] or plugin.src
    if src and not src:find('://') then
      src = 'https://github.com/' .. src
    end

    -- Update the plugin table with the full URL
    plugin[1] = src

    -- Execute with error handling
    local ok, err = pcall(vim.pack.add, plugin)
    if not ok then
      vim.notify('vim.pack Error: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

return M
