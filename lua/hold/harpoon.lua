-- Harpoon v1 — force a single global list named "_global" without using internals
return {
  'ThePrimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },

  -- Make sure the global key is set BEFORE harpoon is required by anything
  init = function()
    vim.g.harpoon_project_key = '_global'
  end,

  config = function()
    local harpoon = require('harpoon')
    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')

    -- Belt-and-suspenders: if Harpoon calls this, it ALWAYS gets "_global"
    harpoon.get_project_key = function()
      return '_global'
    end

    -- Helpers
    local function shorten(p)
      return vim.fn.fnamemodify(p, ':~:.')
    end
    local function json_path()
      return vim.fn.stdpath('data') .. '/harpoon.json'
    end

    -- Quick menu (short paths) with Open/Delete choice
    local function quick_menu()
      local marks = harpoon.get_mark_config().marks
      if vim.tbl_isempty(marks) then
        vim.notify('Harpoon list is empty', vim.log.levels.INFO)
        return
      end
      local entries = {}
      for i, m in ipairs(marks) do
        entries[i] = i .. '. ' .. shorten(m.filename)
      end
      vim.ui.select(entries, { prompt = 'Harpoon Files' }, function(_, idx)
        if not idx then
          return
        end
        vim.ui.select({ 'Open', 'Delete' }, { prompt = 'Action' }, function(choice)
          if choice == 'Open' then
            ui.nav_file(idx)
          end
          if choice == 'Delete' then
            mark.rm_file(idx)
            vim.notify('Removed #' .. idx)
          end
        end)
      end)
    end

    -- Utilities: show/open/reset the state file
    vim.api.nvim_create_user_command('HarpoonPath', function()
      vim.notify(json_path(), vim.log.levels.INFO)
    end, { desc = 'Show harpoon.json path' })

    vim.api.nvim_create_user_command('HarpoonOpen', function()
      vim.cmd.edit(json_path())
    end, { desc = 'Open harpoon.json' })

    vim.api.nvim_create_user_command('HarpoonReset', function()
      local p = json_path()
      vim.fn.delete(p)
      vim.notify('Deleted ' .. p .. ' (will be recreated)', vim.log.levels.INFO)
    end, { desc = 'Delete harpoon.json' })

    -- Migrate: rewrite the JSON file so ALL marks live under "_global"
    vim.api.nvim_create_user_command('HarpoonMigrateGlobal', function()
      local p = json_path()
      local ok, data = pcall(vim.fn.readfile, p)
      local raw = (ok and data and #data > 0) and table.concat(data, '\n') or nil

      local decoded = {}
      if raw and raw ~= '' then
        local okj, v = pcall(vim.json.decode, raw)
        if okj and type(v) == 'table' then
          decoded = v
        end
      end

      decoded.projects = decoded.projects or {}
      -- collect all marks from every project
      local global = decoded.projects._global or { mark = { marks = {} }, term = { cmds = {} } }
      local seen = {}
      for _, m in ipairs(global.mark.marks) do
        seen[m.filename] = true
      end

      for key, proj in pairs(decoded.projects) do
        if
          key ~= '_global'
          and type(proj) == 'table'
          and proj.mark
          and type(proj.mark.marks) == 'table'
        then
          for _, m in ipairs(proj.mark.marks) do
            if m and m.filename and not seen[m.filename] then
              table.insert(global.mark.marks, { filename = m.filename, row = 0, col = 0 })
              seen[m.filename] = true
            end
          end
          -- clear migrated project marks
          proj.mark.marks = {}
        end
      end

      decoded.projects._global = global

      -- write back prettily
      local out = vim.json.encode(decoded)
      vim.fn.writefile(vim.split(out, '\n'), p)
      vim.notify('Harpoon: migrated all project marks into _global → ' .. p, vim.log.levels.INFO)
    end, { desc = 'Merge all project marks into the _global list' })

    -- Keymaps
    vim.keymap.set('n', '<leader>ha', mark.add_file, { desc = 'Harpoon: Add file' })
    vim.keymap.set('n', '<leader>hh', quick_menu, { desc = 'Harpoon: Quick menu (open/delete)' })
    vim.keymap.set('n', '<leader>hd', mark.rm_file, { desc = 'Harpoon: Remove current file' })
    vim.keymap.set('n', '<leader>h1', function()
      ui.nav_file(1)
    end, { desc = 'Harpoon: File 1' })
    vim.keymap.set('n', '<leader>h2', function()
      ui.nav_file(2)
    end, { desc = 'Harpoon: File 2' })
    vim.keymap.set('n', '<leader>h3', function()
      ui.nav_file(3)
    end, { desc = 'Harpoon: File 3' })
    vim.keymap.set('n', '<leader>h4', function()
      ui.nav_file(4)
    end, { desc = 'Harpoon: File 4' })
    vim.keymap.set('n', '<leader>hp', ui.nav_prev, { desc = 'Harpoon: Previous' })
    vim.keymap.set('n', '<leader>hn', ui.nav_next, { desc = 'Harpoon: Next' })
  end,
}
