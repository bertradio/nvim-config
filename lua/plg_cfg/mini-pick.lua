--    ╭────────────────────────────╮
--    │       mini-pick.lua        │
--    ╰────────────────────────────╯

-- 08/01/26 - split from mini.lua

local pick = require('mini.pick')
local extra = require('mini.extra')
local exclude = require('file_exclude')
local visits = require('mini.visits')

visits.setup()

pick.setup({
  mappings = {
    choose_in_split = '<M-s>',
    choose_in_tabpage = '',
    choose_in_vsplit = '<M-v>',
    paste = '<C-v>',
    scroll_down = '<PageDown>',
    scroll_up = '<PageUp>',
  },
  options = {
    use_cache = true,
  },
})
extra.setup()

local files_request = 0

local function files_by_name(opts)
  opts = opts or {}

  local cwd = opts.cwd or vim.fn.getcwd()
  local name = opts.name or 'cwd by name'

  if vim.fn.executable('rg') == 0 then
    vim.notify('ripgrep is required to list files by name', vim.log.levels.ERROR)
    return
  end

  files_request = files_request + 1
  local request = files_request

  pick.start({
    source = {
      cwd = cwd,
      items = function()
        vim.system(
          { 'rg', '--files', '--glob', '!**/.git/**' },
          { cwd = cwd, text = true },
          function(result)
            vim.schedule(function()
              local picker_opts = pick.get_picker_opts()
              if
                request ~= files_request
                or picker_opts.source == nil
                or picker_opts.source.cwd ~= cwd
                or picker_opts.source.name ~= name
              then
                return
              end

              if result.code ~= 0 then
                local message = vim.trim(result.stderr or '')
                vim.notify(
                  message ~= '' and message or 'Could not list files with ripgrep',
                  vim.log.levels.ERROR
                )
                pick.set_picker_items({})
                return
              end

              local files = vim.split(result.stdout or '', '\n', { trimempty = true })
              files = vim.tbl_filter(function(path)
                return not exclude.is_excluded(path)
              end, files)

              table.sort(files, function(a, b)
                local name_a = vim.fs.basename(a):lower()
                local name_b = vim.fs.basename(b):lower()

                if name_a == name_b then
                  return a:lower() < b:lower()
                end

                return name_a < name_b
              end)

              pick.set_picker_items(files)
            end)
          end
        )
      end,
      name = name,
    },
  })
end

local function zoxide_picker()
  if vim.fn.executable('zoxide') == 0 then
    vim.notify('zoxide is not installed or not in PATH', vim.log.levels.ERROR)
    return
  end

  local zoxide_dirs = vim.fn.systemlist({ 'zoxide', 'query', '--list' })
  if vim.v.shell_error ~= 0 then
    vim.notify('Could not read zoxide directories', vim.log.levels.ERROR)
    return
  end

  pick.start({
    source = {
      items = zoxide_dirs,
      name = 'Zoxide directories',
      choose = function(dir)
        return pick.builtin.files(nil, {
          source = { cwd = dir },
        })
      end,
    },
  })
end

--  ───────── keymaps ──────────

Kset('n', '<Leader><space>', files_by_name, { desc = 'mini.pick files' })

Kset('n', '<Leader>]', function()
  vim.cmd.wshada()
  extra.pickers.oldfiles()
end, { desc = 'mini.pick.oldfiles' })

Kset('n', '<Leader>p.', function()
  pick.builtin.resume()
end, { desc = 'resume last picker' })

Kset('n', '<Leader>pb', function()
  pick.builtin.buffers()
end, { desc = 'buffers' })

Kset('n', '<Leader>pc', function()
  extra.pickers.history({ scope = ':' })
end, { desc = 'command history' })

Kset('n', '<Leader>pd', function()
  extra.pickers.diagnostic({ scope = 'current' })
end, { desc = 'diagnostics' })

Kset('n', '<Leader>pe', function()
  extra.pickers.explorer({
    filter = exclude.mini_explorer_filter,
  })
end, { desc = 'explorer' })

Kset('n', '<Leader>pg', function()
  pick.builtin.grep()
end, { desc = 'grep' })

Kset('n', '<Leader>pG', function()
  pick.builtin.grep_live()
end, { desc = 'live grep' })

Kset('n', '<Leader>pH', function()
  extra.pickers.hl_groups()
end, { desc = 'highlights' })

Kset('n', '<Leader>pj', function()
  extra.pickers.list({ scope = 'jump' })
end, { desc = 'jumps' })

Kset('n', '<Leader>pk', function()
  extra.pickers.keymaps()
end, { desc = 'keymaps' })

Kset('n', '<Leader>pl', function()
  extra.pickers.buf_lines({ scope = 'current' })
end, { desc = 'lines' })

Kset('n', '<Leader>pm', function()
  extra.pickers.marks()
end, { desc = 'marks' })

Kset('n', '<Leader>pq', function()
  extra.pickers.list({ scope = 'quickfix' })
end, { desc = 'quickfix' })

Kset('n', '<Leader>pr', function()
  extra.pickers.registers()
end, { desc = 'registers' })

Kset('n', '<Leader>ps', function()
  extra.pickers.history({ scope = '/' })
end, { desc = 'search history' })

Kset('n', '<Leader>pv', function()
  local sort_frequent = visits.gen_sort.default({ recency_weight = 1 })
  visits.select_path('', { sort = sort_frequent })
end, { desc = 'visits - recent' })

Kset('n', '<Leader>pw', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cword>'),
    method = 'fixed',
  })
end, { desc = 'grep word under cursor' })

Kset('n', '<Leader>pW', function()
  pick.builtin.grep({
    pattern = vim.fn.expand('<cWORD>'),
    method = 'fixed',
  })
end, { desc = 'grep WORD under cursor' })

Kset('n', '<Leader>px', function()
  extra.pickers.list({ scope = 'change' })
end, { desc = 'changes' })

Kset('n', '<Leader>pz', zoxide_picker, { noremap = true, silent = true, desc = 'Zoxide' })

Kset('n', 'zz', function()
  extra.pickers.spellsuggest()
end, { desc = 'spell suggest' })
