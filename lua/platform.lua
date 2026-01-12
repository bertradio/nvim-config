-- platform.lua
-- Small cross-platform helpers (Windows-safe)

local M = {}

function M.is_windows()
  return vim.fn.has("win32") == 1
end

function M.pathsep()
  return M.is_windows() and ";" or ":"
end

-- Normalize a path for comparison (not for display).
local function norm(p)
  if not p or p == "" then return "" end
  local is_win = M.is_windows()
  if is_win then
    p = p:gsub("/", "\\")
    p = p:gsub("\\+$", "") -- trim trailing backslashes
    p = p:gsub("^([A-Za-z]):", function(d) return d:upper() .. ":" end)
    return p:lower()
  else
    if p ~= "/" then p = p:gsub("/+$", "") end
    return p
  end
end

-- Add a directory to $PATH (cross-platform, idempotent).
-- Defaults to prepending. Pass { append = true } to append.
function M.add_to_vim_path(dir, opts)
  opts = opts or {}
  dir = vim.fn.expand(dir)

  if dir == "" then return end
  if vim.fn.isdirectory(dir) ~= 1 then return end

  local sep = M.pathsep()
  local target = norm(dir)
  local cur = vim.env.PATH or ""

  for entry in string.gmatch(cur, "([^" .. sep .. "]+)") do
    if norm(entry) == target then
      return
    end
  end

  if opts.append then
    vim.env.PATH = (cur == "" and dir) or (cur .. sep .. dir)
  else
    vim.env.PATH = (cur == "" and dir) or (dir .. sep .. cur)
  end
end

return M
