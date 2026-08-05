-- dupemap.lua

-- Created: 08/04/26

-- Keymap helper with duplicate detection.
local seen = {}

function Kset(mode, lhs, rhs, opts)
  -- Allow mode to be a string or a table.
  local modes = type(mode) == 'table' and mode or { mode }

  for _, m in ipairs(modes) do
    local key = m .. '\0' .. lhs

    if seen[key] then
      local prev = seen[key]

      vim.schedule(function()
        vim.notify(
          string.format(
            'Duplicate keymap:\n\n%s %s\n\nPrevious: %s:%d\nCurrent : %s:%d',
            m,
            lhs,
            prev.file,
            prev.line,
            debug.getinfo(2, 'S').short_src,
            debug.getinfo(2, 'l').currentline
          ),
          vim.log.levels.WARN
        )
      end)
    end

    local info = debug.getinfo(2, 'Sl')
    seen[key] = {
      file = info.short_src,
      line = info.currentline,
    }
  end

  vim.keymap.set(mode, lhs, rhs, opts)
end
